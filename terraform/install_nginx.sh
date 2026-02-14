  # This script runs on the first boot
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Look to your right, now your in the mix !!!</h1>" > /usr/share/nginx/html/index.html
              EOF