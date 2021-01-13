/*********************************************
 * OPL 12.9.0.0 Model
 * Author: Ervin
 * Creation Date: 05 Dec 2020 at 10:54:24
 *********************************************/
 //indices 
{string}wh_id = ...; // warehouses
{string}client_id = ...;// clients
{int}datetime = ...; //index representing the date
{string}must_open = ...; //subset of wh that msut stay open
{string}production = ...; //subset of production facilities
{string}warehouse = ...; // subeset of wh facilities

//parameters
float out_dist[client_id][wh_id] = ...; //outbound distance matrix
float inb_dist[production][warehouse] = ...; //inbound distance matrix
float exw_orders[client_id][datetime] = ...; // orders to be picked up (exw) per day
float exw_ttkm[client_id][datetime] = ...; // tkm*netweight for orders  from client i at time t

float ddu_orders[client_id][datetime] = ...; // orders to be delivered (ddu) per day
float ddu_ttkm[client_id][datetime] = ...; // tkm*netweight for orders  from client i at time t
float ddu_fix = ...; //rename later

float wh_capacity[wh_id] = ...; // capacity of wh
float wh_fixed_costs[wh_id] = ...; // fixed costs of opening wh
float wh_variable_costs[wh_id] = ...; // variable costs per pallet
int max_wh_open = ...; // max number of warehouses to open
float wh_bl_costs[wh_id] = ...; //costs of fulfilling backlogged orders

int Active_EXW = ...;
int Active_Backlog = ...;
int Active_Inbound = ...;
//decision variables
dvar float+ Pallet_Trans[client_id][wh_id][datetime]; // flow from warehouse i to client j including backlog from t-1
dvar boolean EXW_boolean[client_id][wh_id][datetime]; // pallets to be picked up at wh j including backlog from t-1

dvar boolean Wh_Opened[wh_id]; // boolean true if wh is opened; false otherwise

dvar boolean EXW_Backlog[client_id][wh_id][datetime]; // backlog for a client j at time t
dvar boolean DDU_Backlog[client_id][wh_id][datetime]; // backlog for a client j at time t
dvar float+ Backlog[client_id][wh_id]; // backlog for a client j at time t aggregated

dvar boolean DDU_boolean[client_id][wh_id][datetime]; // 1 if order from client i is fulfiled by wh j at date t; 0 otherwise

dvar float+ Inb_Pallet[production][warehouse][datetime]; // inboud pallet transport

dvar float+ Agg_Pallet_Trans[client_id][wh_id]; //dummy variable: total flow aggreaged for whole time period (datetime)
dvar float+ EXW_Agg[client_id][wh_id]; //dummy variable: EXW flow aggregated for whole time period (datetime)
dvar float+ DDU_Agg[client_id][wh_id]; //dummy variable: DDU flow aggregated for whole time period (datetime)
dvar float+ DDU_Trans_Costs[client_id][wh_id]; //dummy variable: Outbound transportation cost aggregated for whole time period (datetime)
dvar float+ Agg_Inb_Costs[production][warehouse]; //dummy variable:  Inbound transporation cost aggregated for whole time period (datetime)


//objective
minimize
	sum(i in client_id, j in wh_id, t in datetime)Active_EXW*(EXW_boolean[i][j][t]*out_dist[i][j]*exw_ttkm[i][t]) //pick-up transporation costs
	+ sum(j in wh_id)Wh_Opened[j]*wh_fixed_costs[j] // annual fixed costs
	+ sum(j in wh_id,i in client_id, t in datetime)(Pallet_Trans[i][j][t])*wh_variable_costs[j] // wh handling costs (includes backlogged orders)
	+ sum (j in wh_id,i in client_id, t in datetime)(DDU_Trans_Costs[i][j]) // outbound transportation costs (delivery)
	+sum(j in wh_id,i in client_id, t in datetime)Active_Backlog*(Backlog[i][j])*wh_bl_costs[j] //(additional) backlogging penalty costs
	+ sum(p in production, w in warehouse)Active_Inbound*(Agg_Inb_Costs[p][w]*inb_dist[p][w]);  //inbound transporation costs
 


subject to {
DDU_DemandCT: //

forall(i in client_id, t in datetime)(sum(j in wh_id)(DDU_boolean[i][j][t]*ddu_orders[i][t] + DDU_Backlog[i][j][t]*ddu_orders[i][t])) == ddu_orders[i][t];
EXW_DemandCT: // demand met exw
forall(i in client_id, t in datetime)(sum(j in wh_id)(EXW_boolean[i][j][t]*exw_orders[i][t] + EXW_Backlog[i][j][t]*exw_orders[i][t])) == exw_orders[i][t]; 
CapacityCT: //capacity constraint if wh is opened
forall(j in wh_id, t in datetime, p in production)sum(i in client_id)Pallet_Trans[i][j][t] + sum(w in warehouse)Inb_Pallet[p][w][t] <= (wh_capacity[j] * Wh_Opened[j]); 
FacilitiesOpenCT: // Number of wh opened < level of centralization
sum(j in wh_id)Wh_Opened[j] <= max_wh_open;
FacilitiesMustOpenCt: // Facilities that must remain open
forall(j in must_open) Wh_Opened[j] == 1;  

InboundCt:
forall(t in datetime, w in warehouse)sum(p in production) Inb_Pallet[p][w][t] == sum(i in client_id)Pallet_Trans[i][w][t];
DummyVarCT: //aggregate decision variable into 2D array to be able to output
forall(j in wh_id, t in datetime: t>1, i in client_id)(EXW_boolean[i][j][t]*exw_orders[i][t] +
												  DDU_boolean[i][j][t]*ddu_orders[i][t] + 
												  DDU_Backlog[i][j][t-1]*ddu_orders[i][t-1]+ 
												  EXW_Backlog[i][j][t-1]*exw_orders[i][t-1]) == Pallet_Trans[i][j][t]; //total outbound flows in pallets
forall(j in wh_id, i in client_id) Pallet_Trans[i][j][1] == EXW_boolean[i][j][1]*exw_orders[i][1] + DDU_boolean[i][j][1]*ddu_orders[i][1];
forall(i in client_id, j in wh_id)sum(t in datetime)Pallet_Trans[i][j][t] == Agg_Pallet_Trans[i][j]; 
forall(i in client_id, j in wh_id)sum(t in datetime)EXW_boolean[i][j][t]*exw_orders[i][t] == EXW_Agg[i][j]; 
forall(i in client_id, j in wh_id)sum(t in datetime)DDU_boolean[i][j][t]*ddu_orders[i][t] == DDU_Agg[i][j];
forall(i in client_id, j in wh_id)sum(t in datetime)(DDU_Backlog[i][j][t]*ddu_orders[i][t] + EXW_Backlog[i][j][t]*exw_orders[i][t]) == Backlog[i][j];
forall(i in client_id, j in wh_id, t in datetime) sum(t in datetime)((DDU_boolean[i][j][t]+DDU_Backlog[i][j][t])*out_dist[i][j]*ddu_ttkm[i][t]) 
																	 + ddu_fix*DDU_boolean[i][j][t]  == DDU_Trans_Costs[i][j];
forall(p in production, w in warehouse)sum(t in datetime) ((Inb_Pallet[p][w][t]/30)*inb_dist[p][w]) == Agg_Inb_Costs[p][w]; //yearly inbound trans																	 
}


