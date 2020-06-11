## Common Mistakes working with ENet-CSharp

This file describes some mistakes that newcomers or even experienced veterans can make. Here's some that have been collected over time.

### `Packet.Dispose()` called right after sending a packet.

Never dispose a packet after enqueuing it for sending, ENet does that for you automatically, otherwise, a memory access failure will occur.

### `Packet.Dispose()` called more than once per received packet.

The `Packet` structure is a value type thus internal checks will fail for two different copies of a packet, and a memory access failure will occur. Try to keep processing flow under strict control. If the received packet will be sent further, you should not dispose it since ENet will use it as you normally enqueuing a packet for sending.

### Channels limit didn't match at the endpoints.

Always make sure that the channel limit set to the same value at the endpoints using `Host.Create()` and `Host.Connect()` functions. Failure to do so otherwise results in packets will not be delivered on disabled channels.

### Round-trip time is unstable even on localhost.

This is the first indication that the `Host.Service()` is not called often enough. Make sure that the service and events are processed continuously and nothing prevents the ENet to shuttle packets across peers.

### Latency gets higher relatively to a count of concurrent connections.

Make sure that only the actual payload is sent and not a whole buffer, a packet should be created with the correct length using the `Packet.Create()` function. Check that the ENet is not overwhelmed with large [reliably fragmented](https://github.com/SoftwareGuy/ENet-CSharp/DOCUMENTATION.md#packetflags) packets.

### A host is unable to accept multiple connections or degrades with many packets.

Make sure that the service is processing as many events as possible and not only one event per frame/iteration. Put the service into a loop even within a game loop (but without a timeout to avoid blocking). Utilizing C# Threads can help too.

If nothing helps, you can try to increase the socket buffer size of the host up to one megabyte using the appropriate parameter at both ends.

### A host is not flushed after the service is no longer in a loop.

Always flush the host before the end of a session to ensure that all queued packets and protocol commands were sent to its designated peers.

### Unreliable packets are dropped significantly under simulation of latency.

If the simulated delay/ping is applied in the middle of the process, but not before connection establishment, then unreliable packets will be throttled if simulated latency exceeds the threshold (20 ms by default between service updates). See the description of `Peer.ConfigureThrottle()` [here](https://github.com/SoftwareGuy/ENet-CSharp/DOCUMENTATION.md) for details and parameters tuning.

This document will be updated as time goes on.