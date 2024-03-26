# Attackathon

Let's break lightning! 

## Setup

Participants do not need to read the following section, it contains 
instructions on how to setup a warnet network to run the attackathon 
on.

## Payment Bootstrap

To run a realistic attackathon, nodes in the network need to be 
bootstrapped with payment history to build up their reputation scores 
for honest nodes in the network. We're interested in bootstrapping 6 
months of data (as this is the duration we look at in the proposal), 
so we need to simulate and insert that data (rather than leave a warnet 
running for 6 months / try to mess with time).

The steps for payment bootstrapping are:
1. Select desired topology for attackathon
2. Run [SimLN](https://github.com/bitcoin-dev-project/sim-ln) in 
   `sim_network` mode to generate fake payment data for the network 
   with simulation time (not real time).
3. Convert simulation timestamps to real dates.
4. Run warnet with the same topology, and import data via 
   [Circuitbreaker](https://github.com/lightningequipment/circuitbreaker)

### 1. Choose Topology

SimLN requires a description of the desired topology to generate data. 
The [lnd_to_simln.py](./setup/lnd_to_simln.py) script can be used to 
convert the output of LND's `describegraph` command to a simulation 
file for SimLN. This utility is useful when simulating a reduced 
version of the mainnet graph, as you'll already have the data in this 
format.

To convert LND's graph (`graph.json`) to a `sim_graph.json` for SimLN:
`python setup/lnd_to_simln.py graph.json`

To prepare a SimLN file that can be used to generate data for warnet, 
the script will perform the following operations:
- Reformat the graph file to the input format that SimLN requires
- Replace short channel ids with deterministically generated short 
  channel ids: 
  - Block height = 300 + index of channel in json
  - Transaction index = 1
  - Output index = 0
- Set an alias for each node equal to their index in the list of 
  nodes provided in the original graph file.

The script will output a json file with the same name as the input file, 
with a `simln.json` suffix added in the current directory.

### 2. Run SimLN to Generate Data

Next, run SimLN with the generated simulation file setting the total 
time flag to the amount of time that you'd like to generate data for:
`sim-cli --sim-file={path to sim_graph.json} --total-time=1.577e+7`

When the simulator has finished generating data in its simulated 
network, the output will be available in `results/htlc_forwards.csv`.
This file contains a record of every forward that the network has 
processed during the period provided.

### 3. Convert Simulation Timestamps

For the attackathon, we want nodes to have _recent_ timestamps so that 
honest peers reputation is up to date. This means that we'll always 
need to progress the timestamps in `htlc_forwards.csv` to the present 
before running the attackathon warnet. Note that the payment activity 
can be pre-generated, but this "fast fowwarding" must be done at the 
time the warnet is spun up (or future dated to a known start time).

To progress the timestamps in your generated data such that the latest
timestamp reported by the simulation is set to the present (and all 
others are appropriately "fast-forwarded"), use the following command:

`python setup/progress_timestamps.py htlc_forwards.csv`

It will output `htlc_forwards_timewarp.csv` which has the updated 
forwarding data.

### 4. Run warnet


