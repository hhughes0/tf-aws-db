output "instance_tags" {
  value = flatten([
    for a_map in module.aws_ec2[*] : [
      for stage in a_map : [
        for tags in stage : [
          for tag in tags : [
            for tg in tag : [
            { Tags = tg.tags, description = "Instance tag values" }
            ]
          ]
        ]
      ]
    ]
  ])
}
