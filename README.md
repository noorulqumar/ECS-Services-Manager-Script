# ECS-Services-Manager-Script

This is for manage the Desire task of services in the development cluster.

We have a requirnment, if a task is deployed more then 6 day in dev environment, we will set the desire task to 0, to minimize the cost.
We also have 2 services Acticepices and baserow which we want to skip.

we are running this by settng up a cron job on EC2.

When developer will work again it push changes, it will create a task automaatically.
