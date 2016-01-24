Drone on ECS
============

**Author**: [Darren Coxall](https://github.com/dcoxall)

This repository serves as an example of how to get a fully functioning [Drone
CI][drone] container running on [AWS EC2 Container Service][ecs]. The method
selected for this is to use [CloudFormation][cloudformation] which makes it easy
to cleanup your account afterwards, alter your setup and completely re-produce
your environment when necessary.

What does the template do
-------------------------

The provided template will provision systems within your AWS account and these
will have associated costs. Please check the template before running it so you
understand what is being set-up and to avoid any surprises.

The template does the following:

- Defines a task for Drone forwarding host port 80 to container port 8000
- Creates an auto scaling group that ensures a single instance is running
- Creates a load balancer sends traffic on port 80 to the host port 80
- Defines an ECS cluster and service that links the load balancer, instance and
  task
- Applies security groups to the instance and load balancer to ensure we can:
  * SSH onto the instance if we need to debug
  * Prevents direct traffic (all HTTP must come from the load balancer)
- Creates necessary IAM roles to ensure instances can register to the cluster

Usage
-----

Clone this repository or copy the template into a directory. Using the [aws
command line tools][cli] you can then follow the steps detailed below.

Create a file that will store our template parameters. These can be provided
directly using the CLI but with a handful to define it gets a bit messy.

    # params.json
    [
        {
            "ParameterKey": "VPC",
            "ParameterValue": "[VPC ID]"
        },
        {
            "ParameterKey": "Subnets",
            "ParameterValue": "[CSV LIST OF SUBNET IDS]"
        },
        {
            "ParameterKey": "KeyName",
            "ParameterValue": "[KEYPAIR NAME]"
        },
        {
            "ParameterKey": "DroneRemoteDriver",
            "ParameterValue": "[DRONE REMOTE_DRIVER VALUE]"
        },
        {
            "ParameterKey": "DroneRemoteConfig",
            "ParameterValue": "[DRONE REMOTE_CONFIG VALUE]"
        }
    ]

There are also 4 optional parameters that can be overridden.

- `DroneMemoryAllocation` - How much memory do you want to dedicate to the Drone
  container
- `DroneCpuUnits` - How many CPU units will be assigned to the Drone container.
  [See here for more information][cpu_units]
- `DroneInstanceType` - The AWS instance type to use. Defaults to m4.large
- `IncomingHttpCidr` - A CIDR range to limit incoming HTTP traffic. _Be
  careful changing this as GitHub needs to be able to communicate with the
  load balancer_

For the most part, these can be left as is unless you wish to run smaller instances in which you can adjust the instance type and the memory and cpu
allocation accordingly.

With your parameters defined you can now execute...

    $ aws cloudformation create-stack --stack-name drone-ci \
            --template-body file://template.json \
            --parameters file://params.json \
            --capabilities CAPABILITY_IAM

In the AWS console you will now see cloudformation provisioning your new Drone
setup. Once complete you can check the outputs of the stack to help you
configure your remote driver (i.e. GitHub) with the correct oauth endpoint.

    $ aws cloudformation describe-stacks --stack-name drone-ci \
            --query 'Stacks[0].Outputs[0].OutputValue' \
            --output text

This value is also the URL you can use to access your installation.

Contributing
------------

See room for improvement? Have a suggesstion? or even discovered an issue or
bug? Please feel welcome to contribute to the project with a pull request or an
issue.

License
-------

This project is licensed under an [Apache License 2.0][license].

[drone]: https://github.com/drone/drone
[ecs]: https://aws.amazon.com/ecs/
[cloudformation]: https://aws.amazon.com/cloudformation/
[cli]: https://aws.amazon.com/cli/
[cpu_units]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#ContainerDefinition-cpu
[license]: https://www.apache.org/licenses/LICENSE-2.0.html
