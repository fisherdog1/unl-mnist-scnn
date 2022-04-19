# unl-mnist-scnn
Stochastic implementation of MNIST digit recognition neural network.

Designed to be implemented using Intel Quartus tools and tested on Intel MAX10 devices.

# Network Parameters
From the tools directory, use the following command to assemble the network parameters in model_parameters, as well as the test image, into the required .hex initialization files. A pre-built .hex is included in tools.
`python paramtohex.py -I ../model_params/three.png -p ../model_params/Parameter5.npy -p ../model_params/Parameter6.npy -p ../model_params/Parameter87.npy -p ../model_params/Parameter88.npy -p ../model_params/Parameter193.npy -p ../model_params/Parameter194.npy -A 1024`