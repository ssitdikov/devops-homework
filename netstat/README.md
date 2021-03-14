# What is about our connections?

Magic script for getting information by connections.

You can use script:
- step by step
- by parametrization

For running step by step you must run script without parameters for filtering and fetching num of rows:
```shell
./whocn.sh
```
It calls navigation menu for setting PID or/and name of process, result of rows or run with default parameters  
```shell
1) Set up PID of process
2) Set up name of process
3) Set up max result rows
0) Run
```
Another way is using parameters. Some examples:
```shell
./whocn.sh -p 2010 -n "another" -r 10  
```
It returns last `10` records of connections with PID `2010` processes and name - `another`