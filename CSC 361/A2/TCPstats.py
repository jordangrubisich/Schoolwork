#!/usr/bin/env python3

#Jordan Grubisich
#V00951272
#CSC361 - Assignment 2
#TCPstats.py


from struct import unpack
import sys
from packet_struct import *

# Class representing a single connection
class connection():
    connection_no = 0
    source_ip = 0
    source_port = 0
    dest_ip = 0
    dest_port = 0
    status = ''
    start_time = 0
    end_time = 0
    num_packets_s2d = 0
    num_packets_d2s = 0
    num_bytes_s2d = 0
    num_bytes_d2s = 0
    closed = True
    num_syn = 0
    num_fin = 0
    num_rst = 0
    packets = []

    def __init__(self):
        self.connection_no = 0
        self.source_ip = 0
        self.source_port = 0
        self.dest_ip = 0
        self.dest_port = 0
        self.status = ''
        self.start_time = 0
        self.end_time = 0
        self.num_packets_s2d = 0
        self.num_packets_d2s = 0
        self.num_bytes_s2d = 0
        self.num_bytes_d2s = 0
        self.closed = True
        self.num_syn = 0
        self.num_fin = 0
        self.num_rst = 0
        self.packets = []


#Swap Endianness of passed in byte object
def swap(bytes,rev):
    if rev:
        return bytes[::-1]
    return bytes


#Reads provided capfile and creates connection objects populated with packet object and other info about the connection
def read_capfile(file_name: str):
    rev = False
    f = open(file_name,"rb")
    global_header = f.read(24)

    magic_number = global_header[:4]
    if magic_number == b'\xd4\xc3\xb2\xa1':
        rev = True


    connection_dict = {}

    #Global Header Information
    version_major = swap(global_header[4:6], rev)
    version_minor = swap(global_header[6:8], rev)
    thiszone = swap(global_header[8:12], rev)
    sigfigs = swap(global_header[12:16], rev)
    snaplen = swap(global_header[16:20], rev)
    network = swap(global_header[20:24], rev)

    cur_read = f.read(16)
    x = 1
    y = 1
    orig_seq_num = 2187554249
    orig_time = 0.0
    orig_ack_num = 0
    while cur_read != b'':
        p = packet()
        t = TCP_Header()
        i = IP_Header()

        #Packet Header Information
        ts_sec = cur_read[:4]
        ts_usec = cur_read[4:8]
        incl_len = swap(cur_read[8:12],rev)
        incl_len = int.from_bytes(incl_len,'big')
        orig_len = swap(cur_read[12:16],rev)

        p.packet_No_set(x)
        if x == 1:
            start_seconds = struct.unpack('I',ts_sec)[0]
            start_microseconds = struct.unpack('<I',ts_usec)[0]
            orig_time = round(start_seconds+start_microseconds*0.000001,6)
        p.timestamp_set(ts_sec,ts_usec,orig_time) 

        #Read in Packet Data
        cur_read = f.read(incl_len)

        #IPV4 Header Information
        ipv4_header = cur_read[14:34]
        i.get_header_len(ipv4_header[:1])
        ihl = i.ip_header_len
        ipv4_header = cur_read[14:14 + ihl]
        i.build_ip(ipv4_header)
        protocol = struct.unpack("B",ipv4_header[9:10])[0]
        
        #Exclude non TCP packets
        if protocol != 6:
            cur_read = f.read(16)
            continue


        #TCP Header Information
        tcp_header = cur_read[14 + ihl:(14 + ihl) + 20]
        t.get_data_offset(tcp_header[12:13])
        tcp_header = cur_read[14 + ihl:(14 + ihl) + t.data_offset]
        t.build_tcp(tcp_header)
        
        

        p.IP_header = i
        p.TCP_header = t
        p.set_data_len()

        
        #get 4-tuple info
        p_s_ip = p.IP_header.src_ip
        p_s_port = p.TCP_header.src_port
        p_d_ip = p.IP_header.dst_ip
        p_d_port = p.TCP_header.dst_port
        
        #build forward and reverse 4-tuple
        packet_tuple = ((p_s_ip,p_s_port),(p_d_ip,p_d_port))
        inv_packet_tuple = ((p_d_ip,p_d_port),(p_s_ip,p_s_port))

        #find a connection for this packet
        if (packet_tuple not in connection_dict) and (inv_packet_tuple not in connection_dict): 
            #connection doesnt yet exist, create new connection
            c = connection()
            c.connection_no = y
            y = y + 1
            c.source_ip = p_s_ip
            c.dest_ip = p_d_ip
            c.source_port = p_s_port
            c.dest_port = p_d_port
            c.packets.append(p)
            connection_dict[packet_tuple] = c
        elif (packet_tuple in connection_dict):
            #forward connection 4-tuple exists, add to that connection
            connection_dict[packet_tuple].packets.append(p)
        elif (inv_packet_tuple in connection_dict):
            #reverse connection 4-tuple exists, add to that connection
            connection_dict[inv_packet_tuple].packets.append(p)
            


        x = x + 1
        cur_read = f.read(16)

    
    return connection_dict

# Populates the remaining attributes of each connection object in dictionary of connections
def fill_connections(cons):
    cur_con = connection()
    for connect in cons.items():
        time_stamps = []
        cur_con = connect[1]
        source = cur_con.source_ip
        dest = cur_con.dest_ip
        
        for pac in cur_con.packets:
            #increment connection flag count
            cur_con.num_syn = cur_con.num_syn + pac.TCP_header.flags["SYN"]
            cur_con.num_fin = cur_con.num_fin + pac.TCP_header.flags["FIN"]
            cur_con.num_rst = cur_con.num_rst + pac.TCP_header.flags["RST"]

            #packet is transmitting from source to dest
            if pac.IP_header.src_ip == source:
                cur_con.num_packets_s2d = cur_con.num_packets_s2d + 1
                cur_con.num_bytes_s2d = cur_con.num_bytes_s2d + pac.data_len
            #packet is transmitting from dest to source
            elif pac.IP_header.src_ip == dest:
                cur_con.num_packets_d2s = cur_con.num_packets_d2s + 1
                cur_con.num_bytes_d2s = cur_con.num_bytes_d2s + pac.data_len

            #Generate list of all time stamps
            time_stamps.append(pac.timestamp)

            for com in cur_con.packets:
                if pac.is_corresponding(com):
                    pac.get_RTT_value(com)
            if pac.TCP_header.flags["FIN"] == 1:
                cur_con.end_time = pac.timestamp
            
        cur_con.start_time = cur_con.packets[0].timestamp
        cur_con.status = "S{syn}F{fin}".format(syn = cur_con.num_syn, fin = cur_con.num_fin)
        if cur_con.num_rst > 0:
            cur_con.status = cur_con.status + "/R"
        if cur_con.num_fin == 0:
            cur_con.closed = False

    return

#Prints parts A and B of the output: total number of connections and a list of each connection in the dictionary of connections
def print_connections(cons):
    print(f"A) Total number of connections: {len(cons)}")
    print("_______________________________________________\n")
    print("B) Connection's details\n")
    for con in cons.values():
        print(f"Connection {con.connection_no}:")
        print(f"Source Address: {con.source_ip}")
        print(f"Destination Address: {con.dest_ip}")
        print(f"Source Port: {con.source_port}")
        print(f"Destination Port: {con.dest_port}")
        print(f"Status: {con.status}")
        if con.closed:
            print(f"Start time: {con.start_time} seconds")
            print(f"End Time: {con.end_time} seconds")
            print(f"Duration: {round(con.end_time - con.start_time,6)} seconds")
            print(f"Number of packets sent from Source to Destination: {con.num_packets_s2d}")
            print(f"Number of packets sent from Destination to Source: {con.num_packets_d2s}")
            print(f"Total number of packets: {len(con.packets)}")
            print(f"Number of data bytes sent from Source to Destination: {con.num_bytes_s2d}")
            print(f"Number of data bytes sent from Destination to Source: {con.num_bytes_d2s}")
            print(f"Total number of data bytes: {con.num_bytes_s2d + con.num_bytes_d2s}")
            print("END")
        if con.connection_no < len(cons):
            print("+++++++++++++++++++++++++++++++")
    print("_______________________________________________\n")

    return

# Calculates and prints parts C and D of the output: Number of complete/reset/still open TCP connections and stats of completed connections
def print_stats(cons):

    complete = 0
    reset = 0
    open = 0

    for con in cons.values():
        if con.closed:
            complete = complete + 1
        if "/R" in con.status:
            reset = reset + 1
        if not con.closed:
            open = open + 1


    print("C) General\n")
    print(f"Total number of complete TCP connections: {complete}")
    print(f"Number of reset TCP connections: {reset}")
    print(f"Number of TCP connections that were still open when the trace capture ended: {open}")
    print("_______________________________________________\n")

    durs = []
    rtts = []
    num_pacs = []
    win_sizes = []

    for con in cons.values():
        if con.closed:
            durs.append(round(con.end_time - con.start_time,6))
        if con.closed:
            num_pacs.append(con.num_packets_s2d + con.num_packets_d2s)
        for pac in con.packets:
            if pac.RTT_flag and con.closed:
                rtts.append(max(pac.RTT_value,0))
            if con.closed:    
                win_sizes.append(pac.TCP_header.window_size)
    
    print("D) Complete TCP connections\n")
    print(f"Minimum time duration: {min(durs)} seconds")
    print(f"Mean time duration: {round(sum(durs)/len(durs),6)} seconds")
    print(f"Minimum time duration: {max(durs)} seconds\n")

    print(f"Minimum RTT value: {min(rtts)} seconds")
    print(f"Mean RTT value: {round(sum(rtts)/len(rtts),6)} seconds")
    print(f"Maximum RTT value: {max(rtts)} seconds\n")

    print(f"Minimum number of packets including both send/received: {min(num_pacs)}")
    print(f"Mean number of packets including both send/received: {round(sum(num_pacs)/len(num_pacs),6)}")
    print(f"Maximum number of packets including both send/received: {max(num_pacs)}\n")

    print(f"Minimum receive window size including both send/received: {min(win_sizes)} bytes")
    print(f"Mean receive window size including both send/received: {round(sum(win_sizes)/len(win_sizes),6)} bytes")
    print(f"Maximum receive window size including both send/received: {max(win_sizes)} bytes")
    print("_______________________________________________\n")

    return

def main() -> None:
    if len(sys.argv) > 2:
        print("Invalid number of arguments\nUse format: python3 TCPstats.py {capfilename.cap}")
        return
    capfile_name = sys.argv[1]
    
    connection_dict = read_capfile(capfile_name)
    
    fill_connections(connection_dict)

    print_connections(connection_dict)

    print_stats(connection_dict)
    return

if __name__ == "__main__":
    main()