addMATSimAttribsXML <- function(cp, pp){
  cp <- cp %>% 
    select(PERSID, HHID, AGE, SEX, CARLICENCE, MAINACT2)
  
  attrs<-drop(as.matrix(cp)) # get named vector of attributes
  # create person attributes
  xattr<-lapply(
    seq_along(attrs),
    function(i,x,n) { 
      xx<-newXMLNode("attribute", attrs=c(name = n[[i]], class="java.lang.String"))
      xmlValue(xx)<-x[[i]]
      xx
    }, 
    x=attrs, 
    n=names(attrs))
  # assign attribute list to attributes tag
  xattrs<-newXMLNode("attributes")
  addChildren(xattrs,xattr) 
  # attach attributes to person
  addChildren(pp,xattrs) 
  return(pp)
}



addMATSimActsAndLegsXML <- function(pp, acts, legs){
  xacts<-apply(
    acts, 1,
    function(x) {
      n<-newXMLNode("activity", attrs=c(type=x[[2]], x=x[[4]], y=x[[5]], end_time=x[[7]]))
    })
  # create the legs
  xlegs<-apply(
    legs, 1,
    function(x) { 
      n<-newXMLNode("leg", attrs=c(x[2]))
      n
    })
  #interleave the activities and legs
  idx <- order(c(seq_along(xacts), seq_along(xlegs)))
  xactslegs<-(c(xacts,xlegs))[idx]
  #create a new plan
  xplan<-newXMLNode("plan", attrs=c(selected="yes"))
  # attach the activities and legs to the plan
  addChildren(xplan,xactslegs)
  #attach plan to person
  addChildren(pp,xplan)
  return(pp)  
}