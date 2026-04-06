# Política autónoma (ACT1.5): recurso aws_instance
# Evaluar con el mismo tfplan.json:
#   opa eval -i tfplan.json -d terraform_ec2_policy.rego "data.terraform.ec2.instance_allow"
#
# true  = no hay creación de EC2, o todas las que se crean usan instance_type t2.micro
# false = alguna instancia que se crea en el plan no es t2.micro

package terraform.ec2

default instance_allow = true

instance_allow = false {
    some i
    rc := input.resource_changes[i]
    rc.type == "aws_instance"
    rc.change.actions[_] == "create"
    rc.change.after.instance_type != "t2.micro"
}
