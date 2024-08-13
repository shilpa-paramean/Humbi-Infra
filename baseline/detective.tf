resource "aws_detective_graph" "primary" {
  count = try(local.workspace.detective.enabled, false) && tostring(try(local.workspace.detective.admin_account_id, "")) == local.workspace.aws_account_id ? 1 : 0
  tags = {
    Name = "detective-graph-${terraform.workspace}"
  }
}

resource "aws_detective_member" "member" {
  for_each      = { for member in try(local.workspace.detective.members, []) : member.account_id => member 
  if try(local.workspace.detective.enabled, false) && tostring(try(local.workspace.detective.admin_account_id, "")) == local.workspace.aws_account_id }
  account_id    = each.value.account_id
  email_address = each.value.email
  graph_arn     = aws_detective_graph.primary[0].graph_arn
}

resource "aws_detective_invitation_accepter" "member" {
  count     = try(local.workspace.detective.enabled, false) && tostring(try(local.workspace.detective.admin_account_id, "")) != local.workspace.aws_account_id ? 1 : 0
  graph_arn = try(local.workspace.detective.admin_graph_arn, "")

  depends_on = [aws_detective_member.member]
}
