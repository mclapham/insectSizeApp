library(shiny)
library(RCurl)

meas_url<-getURL("https://raw.githubusercontent.com/mclapham/insectSizeApp/master/sizedataprep.csv",ssl.verifypeer = FALSE)
meas<-read.csv(text=meas_url)

#reads time interval names, ages, colors
time_int<-read.csv("http://paleobiodb.org/data1.1/intervals/list.txt?scale=1&limit=all")
periods<-subset(time_int,time_int$level==3)

# Define server logic for random distribution application
shinyServer(function(input, output) {
      
  taxonInput<-reactive({
    taxonlist<-read.csv(paste("http://paleobiodb.org/data1.1/taxa/list.txt?name=",input$taxon,"&rel=all_children&status=senior&rank=species&limit=99999",sep=""),fileEncoding = "UTF8")
    subset(meas,meas$species %in% taxonlist$taxon_name)
    })
  
  partInput<-reactive({
    input$bodypart
    })
  
  presInput<-reactive({
    input$preservation
  })
  
  logInput<-reactive({
    input$logaxis
  })
  
  #Size plot
  output$plot<-renderPlot({
    meas<-taxonInput()
    
    body_part<-partInput()
    
    if(body_part=="Wing"){
      meas<-subset(meas,meas$part %in% c("wing","forewing","hindwing","elytron","tegmen","hemelytron"))
    }
    else {meas<-subset(meas,meas$part=="body")}
    
    preservation<-presInput()
    
    if(preservation=="Amber"){
      meas<-subset(meas,meas$amber=="amber")}
    else if(preservation=="Rock") {
      meas<-subset(meas,meas$amber=="not_amber")}
    
    logaxis<-logInput()
    
    layout(matrix(c(1,2),ncol=1),heights=c(3.5,1))
    
    par(mar=c(0,4,2,2))
    if(logaxis=="Log"){
      plot(meas$age_ma,meas$length,xaxt="n",xlab="",ylab=paste(input$bodypart,"length (mm)"),
           xlim=rev(range(meas$age_ma,na.rm=T)),log="y",lwd=2,col=c("chocolate3","slategray4")[meas$amber],bty="n")
    }
    else {plot(meas$age_ma,meas$length,xaxt="n",xlab="",ylab=paste(input$bodypart,"length (mm)"),
          xlim=rev(range(meas$age_ma,na.rm=T)),lwd=2,col=c("chocolate3","slategray4")[meas$amber],bty="n")}
    mtext(paste(input$taxon," (",nrow(meas)," specimens from ",length(unique(meas$species))," species)",sep=""),side=3,adj=0,cex=1.5)
    
    par(mar=c(5,4,0,2))
    par(mgp=c(2,0.75,0))
    plot(0,0,type="n",xlim=rev(range(meas$age_ma,na.rm=T)),xlab="Age (Ma)",yaxt="n",ylab="",ylim=c(0,5),bty="n")
    rect(periods$early_age,0,periods$late_age,5,col=paste(periods$color))
    text(rowMeans(cbind(periods$early_age,periods$late_age)),rep(2.5,nrow(periods)),periods$abbrev)
    })
  
  
  output$downloadData <- downloadHandler(
    
    filename = function() {
      if(nchar(input$taxon)>0) {
        paste(input$taxon, "_sizes.csv", sep = "")
      }
      else {"insect_sizes.csv"}
    },
    
    content = function(file) {
      meas<-taxonInput()
      
      body_part<-partInput()
      
      if(body_part=="Wing"){
        meas<-subset(meas,meas$part %in% c("wing","forewing","hindwing","elytron","tegmen","hemelytron"))
      }
      else {meas<-subset(meas,meas$part=="body")}
      
      preservation<-presInput()
      
      if(preservation=="Amber"){
        meas<-subset(meas,meas$amber=="amber")}
      else if(preservation=="Rock") {
        meas<-subset(meas,meas$amber=="not_amber")}
      
    write.csv(data.frame(species=meas$species,specimen_no=meas$specimen_ID,size_mm=meas$length,
                         body_part=meas$part,collection_no=meas$collection_no,collection_name=meas$collection_name,
                         age_ma=meas$age_ma),file,row.names = FALSE)
    }
  )
})
