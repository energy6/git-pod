#A git plugin for managing repository dependencies.
module GitPod
  #GitPod follows SemVer
  module Version
    #Major version
    MAJOR=0
    #Minor version
    MINOR=0
    #Tiny version
    TINY=1
    #All-in-one
    STRING=[MAJOR,MINOR,TINY].join('.')
  end
end
