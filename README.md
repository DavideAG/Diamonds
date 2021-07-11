# Diamonds
This repository contains a diamond carat prediction model developed on AWS. The whole project also includes the construction of a data engineering pipeline capable of capturing requests from a Kinesis data stream topic and then forwarding them to an API Gateway connected to the model exposed by SageMaker.

The entire architecture respects the serverless paradigm and has been defined using the Terraform modules in the repository.

![image-20210711161121292](C:\Users\d.giorgio\AppData\Roaming\Typora\typora-user-images\image-20210711161121292.png)

DyanamoDB is used to store the predictions of the diamonds and an S3 bucket stores the messages coming from the topic.



This project is part of the exam "Data: Platforms and vendor solutions" of the master 2nd level Specializing Master, AI, ML and Cloud Computing at Politecnico di Torino.
