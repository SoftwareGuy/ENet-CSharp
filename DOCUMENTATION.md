API Reference Documentation
-----
### Enumerations

#### PacketFlags
Definitions of a flags for `Peer.Send()` function:

`PacketFlags.None` unreliable sequenced, delivery of packet is not guaranteed.

`PacketFlags.Reliable` reliable sequenced, a packet must be received by the target peer and resend attempts should be made until the packet is delivered.

`PacketFlags.Unsequenced` a packet will not be sequenced with other packets and may be delivered out of order. This flag makes delivery unreliable.

`PacketFlags.NoAllocate` a packet will not allocate data, and the user must supply it instead. Packet lifetime should be tracked using the `PacketFreeCallback` callback.

`PacketFlags.UnreliableFragmented` a packet will be unreliably fragmented if it exceeds the MTU. By default, unreliable packets that exceed the MTU are fragmented and transmitted reliably. This flag should be used to explicitly indicate packets that should remain unreliable.

`PacketFlags.Instant` a packet will not be bundled with other packets at a next service iteration and sent instantly instead. This delivery type trades multiplexing efficiency in favor of latency. The same packet can't be used for multiple `Peer.Send()` calls.

`PacketFlags.Unthrottled` a packet that was enqueued for sending unreliably should not be dropped due to throttling and sent if possible.

`PacketFlags.Sent` a packet was sent from all queues it has entered.

#### EventType
Definitions of event types for `Event.Type` property:

`EventType.None` no event occurred within the specified time limit.

`EventType.Connect` a connection request initiated by `Peer.Connect()` function has completed. `Event.Peer` returns a peer which successfully connected. `Event.Data` returns the user-supplied data describing the connection or 0 if none is available.

`EventType.Disconnect` a peer has disconnected. This event is generated on a successful completion of a disconnect initiated by `Peer.Disconnect()` function. `Event.Peer` returns a peer which disconnected. `Event.Data` returns the user-supplied data describing the disconnection or 0 if none is available.

`EventType.Receive` a packet has been received from a peer. `Event.Peer` returns a peer which sent the packet. `Event.ChannelID` specifies the channel number upon which the packet was received. `Event.Packet` returns a packet that was received, and this packet must be destroyed using `Event.Packet.Dispose()` function after use.

`EventType.Timeout` a peer has timed out. This event occurs if a peer has timed out or if a connection request initialized by `Peer.Connect()` has timed out. `Event.Peer` returns a peer which timed out.

#### PeerState
Definitions of peer states for `Peer.State` property:

`PeerState.Uninitialized` a peer not initialized.

`PeerState.Disconnected` a peer disconnected or timed out.

`PeerState.Connecting` a peer connection in-progress.

`PeerState.Connected` a peer successfully connected.

`PeerState.Disconnecting` a peer disconnection in-progress.

`PeerState.Zombie` a peer not properly disconnected.

### Delegates
#### Memory callbacks

`AllocCallback(IntPtr size)` notifies when a memory is requested for allocation. Expects pointer to the newly allocated memory. A reference to the delegate should be preserved from being garbage collected.

`FreeCallback(IntPtr memory)` notifies when the memory can be freed. A reference to the delegate should be preserved from being garbage collected.

`NoMemoryCallback()` notifies when memory is not enough. A reference to the delegate should be preserved from being garbage collected.

#### Packet callbacks

`PacketFreeCallback(Packet packet)` notifies when a packet is being destroyed. Indicates if a reliable packet was acknowledged. A reference to the delegate should be preserved from being garbage collected.

#### Host callbacks
Provides per host events.

`InterceptCallback(ref Event @event, ref Address address, IntPtr receivedData, int receivedDataLength)` notifies when a raw UDP packet is intercepted. Status code returned from this callback instructs ENet how the set event should be handled. Returning 1 indicates dispatching of the set event by the service. Returning 0 indicates that ENet subsystems should handle received data. Returning -1 indicates an error. A reference to the delegate should be preserved from being garbage collected.

### Structures
#### Address
Contains structure with anonymous host data and port number.

`Address.Port` gets or sets a port number.

`Address.GetIP()` gets an IP address.

`Address.SetIP(string ip)` sets an IP address. To use IPv4 broadcast in the local network the address can be set to _255.255.255.255_ for a client. ENet will automatically respond to the broadcast and update the address to a server's actual IP. 

`Address.GetHost()` attempts to do a reverse lookup from the address. Returns a string with a resolved name or an IP address.

`Address.SetHost(string hostName)` sets host name or an IP address. Should be used for binding to a network interface or for connection to a foreign host. Returns true on success or false on failure.

#### Event
Contains structure with the event type, managed pointer to the peer, channel ID, the user-supplied data, and managed pointer to the packet.

`Event.Type` returns a type of the event.

`Event.Peer` returns a peer that generated a connect, disconnect, receive or a timeout event.

`Event.ChannelID` returns a channel ID on the peer that generated the event, if appropriate.

`Event.Data` returns the user-supplied data, if appropriate.

`Event.Packet` returns a packet associated with the event, if appropriate.

#### Packet
Contains a managed pointer to the packet.

`Packet.Dispose()` destroys the packet. Should be called only when the packet was obtained from `EventType.Receive` event.

`Packet.IsSet` returns a state of the managed pointer.

`Packet.Data` returns a managed pointer to the packet data.

`Packet.UserData` gets or sets the user-supplied data.

`Packet.Length` returns a length of payload in the packet.

`Packet.HasReferences` checks references to the packet.

`Packet.SetFreeCallback(PacketFreeCallback callback)` sets callback to notify when an appropriate packet is being destroyed. A pointer `IntPtr` to a callback can be used instead of a reference to a delegate.

`Packet.Create(byte[] data, int offset, int length, PacketFlags flags)` creates a packet that may be sent to a peer. The offset parameter indicates the starting point of data in an array, the length is the ending point of data in an array. All parameters are optional. Multiple packet flags can be specified at once. A pointer `IntPtr` to a native buffer can be used instead of a reference to a byte array.

`Packet.CopyTo(byte[] destination)` copies payload from the packet to the destination array.

#### Peer
Contains a managed pointer to the peer and cached ID.

`Peer.IsSet` returns a state of the managed pointer.

`Peer.ID` returns a peer ID. It's always zero on the client side.

`Peer.IP` returns an IP address in a printable form.

`Peer.Port` returns a port number.

`Peer.MTU` returns an MTU.

`Peer.State` returns a peer state described in the `PeerState` enumeration.

`Peer.RoundTripTime` returns a round-trip time in milliseconds.

`Peer.LastRoundTripTime` returns a round-trip time since the last acknowledgment in milliseconds.

`Peer.LastSendTime` returns a last packet send time in milliseconds.

`Peer.LastReceiveTime` returns a last packet receive time in milliseconds.

`Peer.PacketsSent` returns a total number of packets sent during the connection.

`Peer.PacketsLost` returns a total number of lost packets during the connection.

`Peer.PacketsThrottle` returns a ratio of packets throttle depending on conditions of the connection to the peer.

`Peer.BytesSent` returns a total number of bytes sent during the connection.

`Peer.BytesReceived` returns a total number of bytes received during the connection.

`Peer.Data` gets or sets the user-supplied data. Should be used with an explicit cast to appropriate data type.

`Peer.ConfigureThrottle(uint interval, uint acceleration, uint deceleration, uint threshold)` configures throttle parameter for a peer. Unreliable packets are dropped by ENet in response to the varying conditions of the connection to the peer. The throttle represents a probability that an unreliable packet should not be dropped and thus sent by ENet to the peer. The lowest mean round-trip time from the sending of a reliable packet to the receipt of its acknowledgment is measured over an amount of time specified by the interval parameter in milliseconds. If a measured round-trip time happens to be significantly less than the mean round-trip time measured over the interval, then the throttle probability is increased to allow more traffic by an amount specified in the acceleration parameter, which is a ratio to the `Library.throttleScale` constant. 

If a measured round-trip time happens to be significantly greater than the mean round-trip time measured over the interval, then the throttle probability is decreased to limit traffic by an amount specified in the deceleration parameter, which is a ratio to the `Library.throttleScale` constant. When the throttle has a value of `Library.throttleScale`, no unreliable packets are dropped by ENet, and so 100% of all unreliable packets will be sent. When the throttle has a value of 0, all unreliable packets are dropped by ENet, and so 0% of all unreliable packets will be sent. Intermediate values for the throttle represent intermediate probabilities between 0% and 100% of unreliable packets being sent. 

The bandwidth limits of the local and foreign hosts are taken into account to determine a sensible limit for the throttle probability above which it should not raise even in the best of conditions. To disable throttling the deceleration parameter should be set to zero. The threshold parameter can be used to reduce packet throttling relative to measured round-trip time in unstable network environments with high jitter and low average latency which is a common condition for Wi-Fi networks in crowded places. By default the threshold parameter set to `Library.throttleThreshold` in milliseconds.

`Peer.Send(byte channelID, ref Packet packet)` queues a packet to be sent. Returns true on success or false on failure.

`Peer.Receive(out byte channelID, out Packet packet)` attempts to dequeue any incoming queued packet. Returns true if a packet was dequeued or false if no packets available.

`Peer.Ping()` sends a ping request to a peer. ENet automatically pings all connected peers at regular intervals, however, this function may be called to ensure more frequent ping requests.

`Peer.PingInterval(uint interval)` sets an interval at which pings will be sent to a peer. Pings are used both to monitor the liveness of the connection and also to dynamically adjust the throttle during periods of low traffic so that the throttle has reasonable responsiveness during traffic spikes.

`Peer.Timeout(uint timeoutLimit, uint timeoutMinimum, uint timeoutMaximum)` sets a timeout parameters for a peer. The timeout parameters control how and when a peer will timeout from a failure to acknowledge reliable traffic. Timeout values used in the semi-linear mechanism, where if a reliable packet is not acknowledged within an average round-trip time plus a variance tolerance until timeout reaches a set limit. If the timeout is thus at this limit and reliable packets have been sent but not acknowledged within a certain minimum time period, the peer will be disconnected. Alternatively, if reliable packets have been sent but not acknowledged for a certain maximum time period, the peer will be disconnected regardless of the current timeout limit value.

`Peer.Disconnect(uint data)` requests a disconnection from a peer.

`Peer.DisconnectNow(uint data)` forces an immediate disconnection from a peer.

`Peer.DisconnectLater(uint data)` requests a disconnection from a peer, but only after all queued outgoing packets are sent.

`Peer.Reset()` forcefully disconnects a peer. The foreign host represented by the peer is not notified of the disconnection and will timeout on its connection to the local host.

### Classes
#### Host
Contains a managed pointer to the host.

`Host.Dispose()` destroys the host.

`Host.IsSet` returns a state of the managed pointer.

`Host.PeersCount` returns a number of connected peers.

`Host.PacketsSent` returns a total number of packets sent during the session.

`Host.PacketsReceived` returns a total number of packets received during the session.

`Host.BytesSent` returns a total number of bytes sent during the session.

`Host.BytesReceived` returns a total number of bytes received during the session.

`Host.Create(Address? address, int peerLimit, int channelLimit, uint incomingBandwidth, uint outgoingBandwidth, int bufferSize)` creates a host for communicating with peers. The bandwidth parameters determine the window size of a connection which limits the number of reliable packets that may be in transit at any given time. ENet will strategically drop packets on specific sides of a connection between hosts to ensure the host's bandwidth is not overwhelmed. The buffer size parameter is used to set the socket buffer size for sending and receiving datagrams. All the parameters are optional except the address and peer limit in cases where the function is used to create a host which will listen for incoming connections.

`Host.PreventConnections(bool state)` prevents access to the host for new incoming connections. This function makes the host completely invisible from outside, any peer that attempts to connect to it will be timed out.

`Host.Broadcast(byte channelID, ref Packet packet, Peer[] peers)` queues a packet to be sent to a range of peers or to all peers associated with the host if the optional peers parameter is not used. Any zeroed `Peer` structure in an array will be excluded from the broadcast. Instead of an array, a single `Peer` can be passed to function which will be excluded from the broadcast.

`Host.CheckEvents(out Event @event)` checks for any queued events on the host and dispatches one if available. Returns > 0 if an event was dispatched, 0 if no events are available, < 0 on failure.

`Host.Connect(Address address, int channelLimit, uint data)` initiates a connection to a foreign host. Returns a peer representing the foreign host on success or throws an exception on failure. The peer returned will not have completed the connection until `Host.Service()` notifies of an `EventType.Connect` event. The channel limit and the user-supplied data parameters are optional.

`Host.Service(int timeout, out Event @event)` waits for events on the specified host and shuttles packets between the host and its peers. ENet uses a polled event model to notify the user of significant events. ENet hosts are polled for events with this function, where an optional timeout value in milliseconds may be specified to control how long ENet will poll. If a timeout of 0 is specified, this function will return immediately if there are no events to dispatch. Otherwise, it will return 1 if an event was dispatched within the specified timeout. This function should be regularly called to ensure packets are sent and received, otherwise, traffic spikes will occur leading to increased latency. The timeout parameter set to 0 means non-blocking which required for cases where the function is called in a game loop.

`Host.SetBandwidthLimit(uint incomingBandwidth, uint outgoingBandwidth)` adjusts the bandwidth limits of a host in bytes per second.

`Host.SetChannelLimit(int channelLimit)` limits the maximum allowed channels of future incoming connections. 

`Host.SetInterceptCallback(InterceptCallback callback)` sets callback to notify when a raw UDP packet is interecepted. A pointer `IntPtr` to a callback can be used instead of a reference to a delegate.

`Host.Flush()` sends any queued packets on the specified host to its designated peers.

#### Library
Contains constant fields.

`Library.maxChannelCount` the maximum possible number of channels.

`Library.maxPeers` the maximum possible number of peers.

`Library.maxPacketSize` the maximum size of a packet.

`Library.version` the current compatibility version relative to the native library.

`Library.Initialize(Callbacks callbacks)` initializes the native library. Callbacks parameter is optional and should be used only with a custom memory allocator. Should be called before starting the work. Returns true on success or false on failure.

`Library.Deinitialize()` deinitializes the native library. Should be called after the work is done.

`Library.Time` returns a current local monotonic time in milliseconds. It never reset while the application remains alive.
