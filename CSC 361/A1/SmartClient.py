#!/usr/bin/env python3

"""
Jordan Grubisich
V00951272
CSC361 - Assignment 1
SmartClient.py
"""

"""
***Imported Functions***
"""
import socket
import ssl
import sys
from typing import List
import re


"""
***Class Definitions***
"""


"""
Class: Cookies
-Represents a cookie, including the name, domain and time to expiry
-print_cookies(None) - Prints a formatted string containing the attributes of the cookie object
"""
class Cookie:
    def __init__(self, name, expire, domain):
        self.name = name
        self.expire = expire
        self.domain = domain

    def print_cookie(self) -> None:
        if self.name != "":
            print(f"cookie name: {self.name}, ",end="")
        if self.expire != "":
            print(f"expiry time: {self.expire}, ",end="")
        if self.domain != "":
            print(f"domain name: {self.domain}",end="")
        print("\n",end="")


"""
***Helper Functions***
"""


"""
supports_http2()
input: url -  string containing url
returns: "yes" or "no" depending on if the host at the provided url supports http2
"""
def supports_http2(url: str) -> str:
    ctxt = ssl.create_default_context()
    ctxt.set_alpn_protocols(['spdy/3', 'h2', 'http/1.1'])
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    wrap_s = ctxt.wrap_socket(s, server_hostname=url)
    wrap_s.connect((url, 443))
    if wrap_s.selected_alpn_protocol() == "h2":
        s.close()
        return "yes"
    s.close()
    return "no"


"""
send_request()
input: url - host address to send request to
       ver - string containing http version number
       path - sting containing path following url
       https - bool indicating whether to use https or not
returns: string containing request response
function: creates socket object and sends request based on provided info, returns request response  
"""
def send_req(url: str, ver: str, path: str, https: bool) -> str:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    if https:
        port_num = 443
    else:
        port_num = 80

    s.connect((url, port_num))

    if https:
        s = ssl.wrap_socket(s)

    req = (f"GET {path} HTTP/{ver}\r\nHost: {url}\r\n\r\n").encode()

    s.send(req)
    resp = s.recv(10000)

    s.close()
    return resp.decode()


"""
supports_https()
input: url - a string containing the url
       path - a string containing the path following the url
output: "yes" or "no" depending on whether or not host supports https, response after redirects
function: determines support of https, also handles redirects and returns the response of final redirect
"""
def supports_https(url: str, path) -> str:
    location = url
    cur_path = path
    x = 0

    while x < 10:
        response = send_req(location, '1.1', cur_path, True)
        response_list = response.split(" ")
        status_code = response_list[1]
        # print(status_code)

        if status_code in ['200', '404', '503', '505']:
            return "yes", response
        elif status_code in ['300', '301', '302', '303', '304', '305', '306', '307']:
            x = x + 1
            new_location = [loc for loc in response.splitlines() if loc.startswith('Location:')]
            new_location = new_location[0].split(" ")[1]
            # print(f"NEW LOCATION {new_location}")
            proto, location, path = parse_input(new_location)

            # print(f"Location: {location}, path: {path}")

            if proto == "http://":
                return "no", response
    return "unknown", response


"""
parse_input()
input: string containing the url input as command line argument
output: the host protocol, url and path as separate strings
function: decomposes the url received from args into host protocol, url and path respectively
"""
def parse_input(dest: str) -> str:
    full = dest
    suffixes = [".com", ".ca", ".org", ".gov"]
    path = "/"
    pre = ""
    if full.startswith("https://"):
        pre = "https://"
        mid = full.split("https://", 1)[1]
    elif full.startswith("http://"):
        pre = "http://"
        mid = full.split("http://", 1)[1]
    else:
        mid = re.split('.com | .ca | .org | .gov', full)[0]

    for suf in suffixes:
        if suf in mid:
            path = mid.split(suf, 1)[1]

    url = mid.split('/')[0]

    if path == "":
        path = "/"

    # print(f"pre:{pre}, url:{url}, path:{path}")

    return pre, url, path


"""
check_password_protected()
input: request response
output: boolean indicating whether or not host is password protected
function: checks status code in request response to determined if host is password protected
"""
def check_password_protected(response: str) -> bool:
    response_list = response.split(" ")
    status_code = response_list[1]
    # print(status_code)

    if status_code == "401":
        return True

    return False


"""
get_cookies()
input: request response
output: list of cookie objects
function: parses request response and creates a list of cookie objects 
"""
def get_cookies(response) -> List[Cookie]:
    response_list = response.splitlines()

    cookie_lines = []
    cookie_list = []

    for line in response_list:
        if line.startswith("Set-Cookie:"):
            cookie_lines.append(line)

    for line in cookie_lines:
        name = ""
        expire = ""
        domain = ""
        cookie_info = line.split(";")
        for entry in cookie_info:
            if entry.startswith("Set-Cookie:"):
                name_long = entry.split(" ")[1]
                name = name_long.split("=")[0]
            if entry.startswith(" expires"):
                expire = entry.split("=")[1]
            if entry.startswith(" domain"):
                domain = entry.split("=")[1]
        #print(f"name: {name} expiry: {expire} domain: {domain}")
        cookie_list.append(Cookie(name, expire, domain))

    return cookie_list


"""
main()
function: takes a url from command line args and prints out http2 support, list of cookies and if host is password protected
"""
def main() -> None:
    if len(sys.argv) > 2:
        print("Invalid number of arguments\nUse format: python3 SmartClient.py {url}")
        return
    cla: str = sys.argv[1]

    socket.setdefaulttimeout(5)
    proto, url, path = parse_input(cla)

    print(f"website: {url}")

    http2: str = supports_http2(url)
    print(f"1. Supports http2: {http2}")

    response = send_req(url, '1.2', path, True)
    password_protected = check_password_protected(response)

    if password_protected:
        print(f"2. List of Cookies: \n3. Password-protected: yes")
        sys.exit()

    https, response = supports_https(url, path)

    list_of_cookies: List[Cookie] = get_cookies(response)

    print("2. List of Cookies: ")
    for c in list_of_cookies:
        c.print_cookie()

    if not password_protected:
        print("3. Password-protected: no")


if __name__ == "__main__":
    main()
