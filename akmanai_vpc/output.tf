output "vpc_id" {
  value = "${aws_vpc.client-vpc.id}"
}
output "aws_private_subnet1" {
  value = "${aws_subnet.private_subnet[1].id}"
}
output "aws_private_subnet2" {
  value = "${aws_subnet.private_subnet[2].id}"
}
output "aws_private_subnet3" {
  value = "${aws_subnet.private_subnet[0].id}"
}
output "aws_public_subnet1" {
  value = "${aws_subnet.public_subnet[1].id}"
}
output "aws_public_subnet2" {
  value = "${aws_subnet.public_subnet[2].id}"
}
output "aws_public_subnet3" {
  value = "${aws_subnet.public_subnet[0].id}"
}
output "aws_eip" {
  value = "${aws_eip.nat_eip.id}"
}
