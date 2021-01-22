# cplex

Optimization tool which was devlopped in order to standardize the network design process of a consultancy specialized in Supply Chains.

## Indices

**wh_id**: refers to the unique identifier assigned to each potential facility, all facilities should be included within this set and each facility name should be distinct.

**client_id**: refers to the unique identifier assigned to each client, all clients should be included within this set and each client name should be distinct.

**datetime**: refers to the time period, the full set of periods for which the optimization is to be applied should be included within this set and each period name should be distinct.

**must_open**: refers to the set of facilities that must operate, the wh_id of each facility that should obey such restriction should be provided here, in case of no such restriction this can be pointed to an empty value.

**production**: refers to the subset of facilities (wh_id) which have production abilities (i.e. set of origin location for the inbound transport).

**warehouse**: refers to the subset of facilities (wh_id) which do not have production abilities (i.e. set of destination location for the inbound transport).



## Parameters

Please note that in general parameters should respect the size set by their respective indices and that a numerical value should be provided for each instance.

**out_dist[client_id][wh_id]:** refers to the outbound matrix between each client and facility

inb_dist[production][warehouse]: refers to the inbound matrix between production facilities and non-production facilities.

**exw_orders[client_id][datetime]:** refers to the orders to be picked up for a specific client at a specific date.

**exw_ttkm[client_id][datetime]:** refers to the pre-processed appropriate ton-kilometer rate multiplied by the respective weight of the order for each respective exw_orders (e.g. the correct tkm rate x weight expressed in tons).

**ddu_orders[client_id][datetime]:** refers to the orders to be delivered for a specific client at a specific date.

**ddu_ttkm[client_id][datetime]:** refers to the pre-processed appropriate ton-kilometer rate multiplied by the respective weight of the order for each respective ddu_orders (e.g. the correct tkm rate x weight expressed in tons).

**ddu_fix:** refers to the fixed starting rate for each outbound route.

**wh_capacity[wh_id]:** refers to the handling capacity per time period, expressed in the same units as ddu_orders and exw_orders.

**wh_fixed_costs[wh_id]:** refers to the fixed costs of opening a facility, note that this cost should reflect the fixed costs for the entirety of the time window defined earlier in datetime.


## Variables

**EXW_boolean[client_id][wh_id][datetime]:** refers to the boolean decision whether to satisfy the pick-up demand for a given client from a given facility at a given time or not.

**DDU_boolean[client_id][wh_id][datetime]:** refers to the boolean decision whether to satisfy the delivery demand for a given client from a given facility at a given time or not.

**EXW_Backlog[client_id][wh_id][datetime]:** refers to the boolean decision whether to backlog the pick-up demand for a given client from a given facility at a given time or not. If this take the value 1, the order will actually be shipped in the next time period (i.e. this signals the decision of backlogging not the execution of a backlogged order).

**DDU_Backlog[client_id][wh_id][datetime]:** refers to the boolean decision whether to backlog the delivery demand for a given client from a given facility at a given time or not. If this take the value 1, the order will actually be shipped in the next time period (i.e. this signals the decision of backlogging not the execution of a backlogged order).

**P****allet_Trans[client_id][wh_id][datetime]:** refers to the actual flow between a client and a facility at a given time. This variable is composed of both pick-up and delivery order as well as the backlogged orders from the previous time period.

**Wh_Opened[wh_id]:** refers to the boolean decision of opening a facility or not, please note that for the given facilities in _must_open_ this variable must assume the value of 1.

**Inb_Pallet[production][warehouse][datetime];** refers to the flow of pallet from non-producing facilities specified in _warehouse_ and producing facilities specified in _production_ at a given time.

**Backlog[client_id][wh_id]:** refers to the aggregation of both exw and ddu orders that are backlogged

**Agg_Pallet_Trans[client_id][wh_id]**: refers to flows as mentioned in _Pallet_Trans_ but aggregated over the whole time period.
