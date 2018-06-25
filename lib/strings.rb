
def id(project)
  id = project.downcase.gsub(" ", "-").gsub(":", "")
end
