
# DeployX

#### A Nginx Website Deployment Script

The DeployX is a user-friendly Bash script designed to streamline the process of deploying a static website on an Nginx server. With a simple command-line interface, this script enables users to install Nginx (if not already installed), configure a new website directory, and set up the necessary server configurations automatically.



### Key Features:

* Automatic Installation: Installs Nginx if it is not already present on the system, ensuring the server is ready for hosting.

* Dynamic Configuration: Prompts users to specify the website directory and desired port number, enabling customized deployments.

* Validation Checks: Includes built-in checks to verify the existence of the specified directory, validate the port number, and ensure that the port is not already in use.

* User Permissions: Ensures that the script runs with root privileges, protecting against unauthorized access.

* Configuration Management: Automatically generates and appends a server block configuration for Nginx, allowing easy access to the hosted website.

* Firewall Integration: Configures UFW (Uncomplicated Firewall) to allow traffic on the specified port, enhancing security without sacrificing accessibility.

* Colorful Output: Provides visually appealing feedback during execution with color-coded messages, improving the user experience.


## Deployment

To use this tool, run these commands in terminal

```bash
  chmod +x deploy.sh
```

And just run the main script 

```
sudo ./deploy.sh
```

#### Thats all...Enjoy and Thank you!!
