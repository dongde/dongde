#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netinet/udp.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <errno.h>
#include <signal.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/un.h>

#define BUFSIZE 1500

struct rec /* format of outgoing UDP data */
{
u_short rec_seq; /* sequence number */
u_short rec_ttl; /* TTL packet left with */
struct timeval rec_tv; /* time packet left */
char msg[32]; /*message*/
};

/* globals */
char recvbuf[BUFSIZE]; /*receive databuffer*/
char sendbuf[BUFSIZE]; /*send databuffer*/

int datalen; /* # bytes of data following ICMP header */
char *host; /* local hostname/IP */
u_short sport, dport; /* source and destination */
int nsent; /* add 1 for each sendto() */
pid_t pid; /* our PID */
int probe, nprobes; /* groups */
int sendfd, recvfd; /* send on UDP sock, read on raw ICMP sock */
int gotalarm;
int optind;//获得<hostname>在argv[]中的索引

/* function prototypes */
const char *icmpcode_v4(int);/* determine the diffrent conditions when routing */
int recv_v4(int, struct timeval *);
void sig_alrm(int);/*timer-signal */
void traceloop(void);/* main loop */
void tv_sub(struct timeval *, struct timeval *);/* calculate tima */
char *Sock_ntop_host(const struct sockaddr *sa, socklen_t salen);/* change the netseq to hostseq */
char *sock_ntop_host(const struct sockaddr *sa, socklen_t salen);/* change the netseq to hostseq */
void sock_set_port(struct sockaddr *sa, socklen_t salen, int port);/* set port */
int sock_cmp_addr(const struct sockaddr *sa1, const struct sockaddr *sa2,socklen_t salen);/* compare the last IP with this time */
struct addrinfo *Host_serv(const char *host, const char *serv, int family, int socktype);/* get the destination IP */

struct proto
{
const char *(*icmpcode)(int);/* pointer which point to function icmpcode_v4()*/
int (*recv)(int, struct timeval *);/* pointer which point to function recv_v4() */
struct sockaddr *sasend; /* sockaddr{} for send, from getaddrinfo */
struct sockaddr *sarecv; /* sockaddr{} for receiving */
struct sockaddr *salast; /* last sockaddr{} for receiving */
struct sockaddr *sabind; /* sockaddr{} for binding source port */
socklen_t salen; /* length of sockaddr{}s */
int icmpproto; /* IPPROTO_xxx value for ICMP */
int ttllevel; /* setsockopt() level to set TTL */
int ttloptname; /* setsockopt() name to set TTL */
} *pr;

struct proto proto_v4 = { icmpcode_v4, recv_v4, NULL, NULL, NULL, NULL, 0,
IPPROTO_ICMP, IPPROTO_IP, IP_TTL };/* init struct proto */

int datalen = sizeof(struct rec); /* defaults */
int max_ttl = 30;/* the max nops */
int nprobes = 3;/* three groups */
u_short dport = 32768 + 666;/* desthost port which not want to be connected */

int main(int argc, char **argv)
{
int c;
struct addrinfo *ai;
char *h;

/*getopt(argc, argv, "a");*/ 

if (argc!=2) 
{ 
perror("usage: traceroute <hostname/IP>");
return 0; 
}
host = argv[optind];/* get IP/hostname */

signal(SIGALRM, sig_alrm);/* send signal and set gotalarm */

ai = Host_serv(host, NULL, AF_INET, 0);/* get the destination IP */

h = Sock_ntop_host(ai->ai_addr, ai->ai_addrlen);/* change the netseq to hostseq */

printf("traceroute to %s (%s): %d hops max, %d byte packets\n",/* print */
ai->ai_canonname ? ai->ai_canonname : h,
h, max_ttl, datalen);

/* initialize according to protocol */
if (ai->ai_family == AF_INET) {/* if it is IPv4 ,then pr=&proto */
pr = &proto_v4;
} else/* else print error massage */
printf("unknown address family %d", ai->ai_family);

pr->sasend = ai->ai_addr; /* contains destination address */
pr->sarecv = calloc(1, ai->ai_addrlen);
pr->salast = calloc(1, ai->ai_addrlen);
pr->sabind = calloc(1, ai->ai_addrlen);
pr->salen = ai->ai_addrlen;

traceloop();/* call main loop function */

exit(0);
}

const char *icmpcode_v4(int code)/* determine the diffrent conditions when routing */
{
static char errbuf[100];
switch (code) {
case 0: return("network unreachable");
case 1: return("host unreachable");
case 2: return("protocol unreachable");
case 3: return("port unreachable");
case 4: return("fragmentation required but DF bit set");
case 5: return("source route failed");
case 6: return("destination network unknown");
case 7: return("destination host unknown");
case 8: return("source host isolated (obsolete)");
case 9: return("destination network administratively prohibited");
case 10: return("destination host administratively prohibited");
case 11: return("network unreachable for TOS");
case 12: return("host unreachable for TOS");
case 13: return("communication administratively prohibited by filtering");
case 14: return("host recedence violation");
case 15: return("precedence cutoff in effect");
default: sprintf(errbuf, "[unknown code %d]", code);
return errbuf;
}
}

void sig_alrm(int signo)
{
gotalarm = 1; /* set flag to note that alarm occurred */
return; /* and interrupt the recvfrom() */
}

void traceloop(void)/* mian loop */
{
int seq, code, done;
double rtt;
int ttl;
struct rec *rec;
struct timeval tvrecv;
char *str;

recvfd = socket(pr->sasend->sa_family, SOCK_RAW, pr->icmpproto);/* SOCK_RAW */
if(recvfd==-1)
{
perror("socket error");
exit(0);
}
setuid(getuid()); /* don't need special permissions anymore */
sendfd = socket(pr->sasend->sa_family, SOCK_DGRAM, 0);/* SOCK_DGRAM */

pr->sabind->sa_family = pr->sasend->sa_family;/* init */
sport = (getpid() & 0xffff) | 0x8000; /* our source UDP port # */
sock_set_port(pr->sabind, pr->salen, htons(sport));
bind(sendfd, pr->sabind, pr->salen);/*bind UDP socket with source port*/

sig_alrm(SIGALRM);/*build signal de*/

seq = 0;
done = 0;
for (ttl = 1; ttl <= max_ttl && done == 0; ttl++) {
setsockopt(sendfd, pr->ttllevel, pr->ttloptname, &ttl, sizeof(int));
bzero(pr->salast, pr->salen);

printf("%2d ", ttl);
fflush(stdout);

for (probe = 0; probe < nprobes; probe++) {
rec = (struct rec *) sendbuf;
rec->rec_seq = ++seq;
rec->rec_ttl = ttl;
gettimeofday(&rec->rec_tv, NULL);

sock_set_port(pr->sasend, pr->salen, htons(dport + seq));
sendto(sendfd, sendbuf, datalen, 0, pr->sasend, pr->salen);

if ( (code = (*pr->recv)(seq, &tvrecv)) == -3)
printf(" *"); /* timeout, no reply */
else {
char str[NI_MAXHOST];

if (sock_cmp_addr(pr->sarecv, pr->salast, pr->salen) != 0) {
if (getnameinfo(pr->sarecv, pr->salen, str, sizeof(str),
NULL, 0, 0) == 0)
printf(" %s (%s)", str,
sock_ntop_host(pr->sarecv, pr->salen));
else
printf(" %s",
sock_ntop_host(pr->sarecv, pr->salen));
memcpy(pr->salast, pr->sarecv, pr->salen);
}
tv_sub(&tvrecv, &rec->rec_tv);
rtt = tvrecv.tv_sec * 1000.0 + tvrecv.tv_usec / 1000.0;
printf(" %.3f ms", rtt);

if (code == -1) /* port unreachable; at destination */
done++;
else if (code >= 0)
printf(" (ICMP %s)", (*pr->icmpcode)(code));
}
fflush(stdout);
}
printf("\n");
}
}

void tv_sub(struct timeval *out, struct timeval *in)
{
if ( (out->tv_usec -= in->tv_usec) < 0) { /* out -= in */
--out->tv_sec;
out->tv_usec += 1000000;
}
out->tv_sec -= in->tv_sec;
}

struct addrinfo *Host_serv(const char *host, const char *serv, int family, int socktype)
{
int n;
struct addrinfo hints, *res;

bzero(&hints, sizeof(struct addrinfo));
hints.ai_flags = AI_CANONNAME; /* always return canonical name */
hints.ai_family = family; /* 0, AF_INET, AF_INET6, etc. */
hints.ai_socktype = socktype; /* 0, SOCK_STREAM, SOCK_DGRAM, etc. */

if ( (n = getaddrinfo(host, serv, &hints, &res)) != 0)
printf("host_serv error for %s, %s: %s",
(host == NULL) ? "(no hostname)" : host,
(serv == NULL) ? "(no service name)" : serv,
gai_strerror(n));

return(res); /* return pointer to first on linked list */
}


/*
return: -3 on timeout
-2 on ICMP time exceeded in transit (caller keeps going)
-1 on ICMP port unreachable (caller is done)
>= return value is some other ICMP unreachable code 
*/
int recv_v4(int seq, struct timeval *tv)
{
int hlen1, hlen2, icmplen, ret;
socklen_t len;
ssize_t n;
struct ip *ip, *hip;
struct icmp *icmp;
struct udphdr *udp;

gotalarm = 0;
alarm(3);
for ( ; ; ) {
if (gotalarm)
return(-3); /* alarm expired */
len = pr->salen;
n = recvfrom(recvfd, recvbuf, sizeof(recvbuf), 0, pr->sarecv, &len);
if (n < 0) {
if (errno == EINTR)
continue;
else
perror("recvfrom error");
}

ip = (struct ip *) recvbuf; /* start of IP header */
hlen1 = ip->ip_hl << 2; /* length of IP header */

icmp = (struct icmp *) (recvbuf + hlen1); /* start of ICMP header */
if ( (icmplen = n - hlen1) < 8)
continue; /* not enough to look at ICMP header */

if (icmp->icmp_type == ICMP_TIMXCEED &&
icmp->icmp_code == ICMP_TIMXCEED_INTRANS) {
if (icmplen < 8 + sizeof(struct ip))
continue; /* not enough data to look at inner IP */

hip = (struct ip *) (recvbuf + hlen1 + 8);
hlen2 = hip->ip_hl << 2;
if (icmplen < 8 + hlen2 + 4)
continue; /* not enough data to look at UDP ports */

udp = (struct udphdr *) (recvbuf + hlen1 + 8 + hlen2);
if (hip->ip_p == IPPROTO_UDP &&
udp->source == htons(sport) &&
udp->dest == htons(dport + seq)) {
ret = -2; /* we hit an intermediate router */
break;
}

} else if (icmp->icmp_type == ICMP_UNREACH) {
if (icmplen < 8 + sizeof(struct ip))
continue; /* not enough data to look at inner IP */

hip = (struct ip *) (recvbuf + hlen1 + 8);
hlen2 = hip->ip_hl << 2;
if (icmplen < 8 + hlen2 + 4)
continue; /* not enough data to look at UDP ports */

udp = (struct udphdr *) (recvbuf + hlen1 + 8 + hlen2);
if (hip->ip_p == IPPROTO_UDP &&
udp->source == htons(sport) &&
udp->dest == htons(dport + seq)) {
if (icmp->icmp_code == ICMP_UNREACH_PORT)
ret = -1; /* have reached destination */
else
ret = icmp->icmp_code; /* 0, 1, 2, ... */
break;
}
}
/* Some other ICMP error, recvfrom() again */
}
alarm(0); /* don't leave alarm running */
gettimeofday(tv, NULL); /* get time of packet arrival */
return(ret);
}

char *sock_ntop_host(const struct sockaddr *sa, socklen_t salen)
{
static char str[128]; /* Unix domain is largest */

if (sa->sa_family==AF_INET) {
struct sockaddr_in *sin = (struct sockaddr_in *) sa;

if (inet_ntop(AF_INET, &sin->sin_addr, str, sizeof(str)) == 0)
return(NULL);
return(str);
}
else
{
snprintf(str, sizeof(str), "sock_ntop_host: unknown AF_xxx: %d, len %d",
sa->sa_family, salen);
return(str);
}
return (NULL);
}

char *Sock_ntop_host(const struct sockaddr *sa, socklen_t salen)
{
char *ptr;

if ( (ptr = sock_ntop_host(sa, salen)) == NULL)
perror("sock_ntop_host error"); /* inet_ntop() sets errno */
return(ptr);
}

void sock_set_port(struct sockaddr *sa, socklen_t salen, int port)
{
if (sa->sa_family==AF_INET) 
{
struct sockaddr_in *sin = (struct sockaddr_in *) sa;

sin->sin_port = port;
return;

}

return;
}

int sock_cmp_addr(const struct sockaddr *sa1, const struct sockaddr *sa2,socklen_t salen)
{
if (sa1->sa_family != sa2->sa_family)
return(-1);

if(sa1->sa_family==AF_INET) {
return(memcmp( &((struct sockaddr_in *) sa1)->sin_addr,
&((struct sockaddr_in *) sa2)->sin_addr,
sizeof(struct in_addr)));
}

return (-1);
}
