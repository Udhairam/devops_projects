terraform { 
  cloud { 
    
    organization = "ample-dev" 

    workspaces { 
      name = "first-ws" 
    } 
  } 
}