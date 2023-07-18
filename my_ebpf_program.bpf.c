#include <stdio.h>
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

struct {
	__uint(type, BPF_MAP_TYPE_PERCPU_ARRAY);
	__uint(max_entries, 1);
	__type(key, __u32);
	__type(value, __u32);
} pkt_counter SEC(".maps");

int counter = 0;

SEC("xdp")
int count_packets(struct xdp_md *ctx) {
    int key = 0;   
    int *p;

    p = bpf_map_lookup_elem(&pkt_counter, &key);
    if (p != 0){
        counter = *p;
    }
    bpf_printk("Packet Count: %d", counter);
    counter++;
    bpf_map_update_elem(&pkt_counter, &key, &counter, BPF_ANY);
    return XDP_PASS;

}

char LICENSE[] SEC("license") = "Dual BSD/GPL";