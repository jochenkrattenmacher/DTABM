# Copyright (C) 2022, Jochen Krattenmacher

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

########################  
### Simulation setup ###
########################

using DrWatson, Random

#Random.seed!(2021) # set a global seed if you want your results to be completely reproducible

@quickactivate "DTABM"

include(srcdir("canteenABM.jl"))

consumption_distribution = ones(25) .* 0.5
consumption_distribution[1:5] /= 2
consumption_distribution[6:7] *= 2

model = initialize_model(;
    n_uniqueclients = 25,
    p_present = 0.5, 
    n_groupsize = 5, 
    consumption_distribution, #initial distribution of eating patterns
    forward_factor = 0.1, 
    #diners at table where majority eats PBF option will increase
    #probability to eat PBF by this factor
)
    
n_days = 210

##########################
### Run the simulation ###
##########################

@time Agents.step!(model, agent_step!, model_step!, n_days) 

##########################  
### Export the results ###
##########################


