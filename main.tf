resource "aws_instance" "instance" {
  ami             = "${data.aws_ami.amazon_linux.id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance_security_group.name}"]
  user_data       = "${file("setup.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance_security_group" {
  name = "instance_security_group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  image_id        = "${data.aws_ami.amazon_linux.id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance_security_group.id}"]
  user_data       = "${file("setup.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_configuration = "${aws_launch_configuration.launch_configuration.id}"
  load_balancers       = ["${aws_elb.elb.name}"]
  availability_zones   = ["${data.aws_availability_zones.all.names[0]}", "${data.aws_availability_zones.all.names[1]}"]
  min_size             = 2
  max_size             = 5

  tag {
    key                 = "Name"
    value               = "goserve-api"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "elb_security_group" {
  name = "elb_security_group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elb" {
  name               = "elb"
  availability_zones = ["${data.aws_availability_zones.all.names[0]}", "${data.aws_availability_zones.all.names[1]}"]
  security_groups    = ["${aws_security_group.elb_security_group.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
}
