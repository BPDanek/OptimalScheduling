# OptimalScheduling
Deep Study of [1]: https://www.pnas.org/content/114/3/462.full

  Urban mobility is rapidly transforming due to the high usage of cellular devices and networks. The increase in usage of mobile devices and decrease in costs associated have in turn increased on demand ride sharing services as the solution for people in dense urban areas to get around quicker and cheaper. This paper attempts to solve the problem of optimizing travel delays and determining shortest routes from ride sharing while satisfying boundary conditions set for delays, travel time, and wait time. The approach to this problem comes in the form of an Integer Linear Programming (ILP) solution algorithm built with MATLAB. The solution begins with developing a city map composed of 31 edges and 20 nodes with predefining  2 cars and 5 passengers at random nodes. The passengers are then defined with a beginning and an end node as the destination while the cars are defined with a start point and a max capacity of passengers. The constraints are defined by: the number of edges a car can travel to pickup a passenger as 5, the travel delay once a passenger is picked up of 4 edges, and the capacity of each car being 3 passengers. The ILP solution results confirm that of [1] in determining the optimal trip assignment and pickup order for each of the cars/passengers with a maximum travel delay of 5 edges and 3 edges for cars 1 and 2, respectively.
  
[1] J. Alonso-Mora, S. Samaranayake, A. Wallar, E. Frazzoli, and D. Rus, "On-demand high-capacity ride-sharing via dynamic trip-vehicle assignment," Proceedings of the National Academy of Sciences, vol. 114, no. 3, pp. 462-467, 2017.

[2] Boyd, S. P., & Vandenberghe, L. (2018). Convex optimization. Cambridge: Cambridge University Press.

[3] Integer Programming. (n.d.). Retrieved from https://www.mathworks.com/discovery/integer-programming.html.

Determining possible paths solves the RV-Graph, RTV-Graph, and stores all the relevant data for the ILP Step. For now, the results are hard coded in the individual .m files.
