plot.clusmca<-function(x, dims = c(1,2), what = c(TRUE,TRUE), cludesc = FALSE, topstdres = 20, attlabs = NULL, binary = FALSE, subplot = FALSE, ...){
  
  act = NULL
  attnam = NULL
  d1 = NULL
  d2 = NULL
  gr = NULL
  out=list()
  if (dim(data.frame(x$attcoord))[2] == 1) {
    stop('There is only one dimension. A 2D scatterplot cannot be produced.')
  } 
  
  dim1=dims[1]
  dim2=dims[2]
  K = max(x$cluster)
  
  dfAtt=data.frame(x1=x$attcoord[,1],x2=x$attcoord[,2])
  
  if (is.null(attlabs)) {
    lab1a=names(x$odata)
    lab1b=lapply(x$odata,function(z) levels(z))
    lab1=rep(lab1a,times=unlist(lapply(lab1b,length)))
    lab2=unlist(lab1b)
    attlabs=paste(lab1,lab2,sep=".")
  }
  
  xallmax=max(max(x$attcoord[,dim1]),max(x$obscoord[,dim1]))
  xallmin=min(min(x$attcoord[,dim1]),min(x$obscoord[,dim1]))
  yallmax=max(max(x$attcoord[,dim2]),max(x$obscoord[,dim2]))
  yallmin=min(min(x$attcoord[,dim2]),min(x$obscoord[,dim2]))
  
  xallmax=max(max(x$attcoord[,dim1]),max(x$obscoord[,dim1]))
  xallmin=min(min(x$attcoord[,dim1]),min(x$obscoord[,dim1]))
  yallmax=max(max(x$attcoord[,dim2]),max(x$obscoord[,dim2]))
  yallmin=min(min(x$attcoord[,dim2]),min(x$obscoord[,dim2]))
  x_all_range=xallmax-xallmin
  y_all_range=yallmax-yallmin
  all_range=max(x_all_range,y_all_range)
  xallmax=xallmin+all_range
  yallmax=yallmin+all_range
  
  xattmax=max(x$attcoord[,dim1])
  xattmin=min(x$attcoord[,dim1])
  yattmax=max(x$attcoord[,dim2])
  yattmin=min(x$attcoord[,dim2])
  x_att_range=xattmax-xattmin
  y_att_range=yattmax-yattmin
  att_range=max(x_att_range,y_att_range)
  xattmax=xattmin+att_range
  yattmax=yattmin+att_range
  ######################################################
  filt = 1*att_range
  att_df=data.frame(d1=x$attcoord[,dim1],d2=x$attcoord[,dim2],attnam=attlabs)
  if(binary == TRUE){
    pres=seq(from=2,to=nrow(dfAtt),by=2)
    att_df=att_df[pres,]
  }
  xact=union(which(att_df$d1> filt),which(att_df$d1< -filt))
  yact=union(which(att_df$d2> filt), which(att_df$d2< -filt))
  xyact=union(xact,yact)
  att_df$act=rep("inner",nrow(att_df))
  att_df$act[xyact]="outer"
  
  glab=paste(rep("C",K),1:K,sep="")
  if (length(x$size) != 1)
  {
    group_df= data.frame(d1=x$centroid[,dim1],d2=x$centroid[,dim2],glab=glab)
  }
  obs_df=data.frame(d1=x$obscoord[,dim1],d2=x$obscoord[,dim2],gr=factor(x$cluster))
  
  
  
  if(what[1]==TRUE && what[2]==FALSE ){
    if (length(x$size) != 1)
    {
      names(group_df)[3] = "gr"
      levels(obs_df$gr) = levels(group_df$gr)
    }
    a=ggplot(data=obs_df,aes(x=d1,y=d2,colour=gr,shape=gr))+xlim(xallmin,xallmax)+ylim(yallmin,yallmax)
    a=a+geom_point(aes(x=d1,y=d2,colour=gr,shape=gr,alpha=.4),size=1,na.rm = TRUE)+theme_bw()
    a=a+theme(legend.position="none",axis.text.x = element_blank(),axis.text.y = element_blank())+xlab("")+ylab("")
    a=a+geom_vline(xintercept=0)+geom_hline(yintercept=0)
    
    if (length(x$size) != 1)
    {
      a=a+geom_point(data=group_df,colour="black",aes(x=d1,y=d2,shape=gr),na.rm=TRUE)+theme(legend.position="none",axis.text.x = element_blank(),axis.text.y = element_blank())
      
      a=a+geom_text_repel(data=group_df,colour="black",aes(label=gr))
    }
    a=a+xlab(paste("Dim.",dims[1])) + ylab(paste("Dim.",dims[2]))  
    #out = a
    out$map=a
    # print(a)
    
  }
  if(what[1]==FALSE && what[2]==TRUE ){
    
    xallmax=xattmax
    xallmin=xattmin
    yallmax=yattmax
    yallmin=yattmin
    
    if(nrow(att_df)>=25){
      decr=(nrow(att_df)-25)*(1/250)
      mysize=5 * (1-decr)
      mysize=max(2,mysize)
    }else{mysize=5}
    
    a=ggplot(data=att_df,aes(x=d1,y=d2))+xlim(xallmin,xallmax)+ylim(yallmin,yallmax)
    a=a+geom_point(alpha=.5,size=.25,na.rm = TRUE)+theme_bw()+xlab("")+ylab("")
    a=a+geom_text_repel(data=subset(att_df,act=="outer"),aes( label = attnam),size=mysize,segment.size = 0.01)
    a=a+geom_text_repel(data=subset(att_df,act!="outer"),aes( label = attnam),size=mysize*.8,segment.size = 0.01)
    if (length(x$size) != 1)
    {  
      a=a+geom_point(data=group_df,aes(x=d1,y=d2,shape=glab),na.rm=TRUE)+theme(legend.position="none",axis.text.x = element_blank(),axis.text.y = element_blank())
      a=a+geom_text_repel(data=group_df,aes(label=glab))
    }
    a=a+geom_vline(xintercept=0)+geom_hline(yintercept=0)
    a=a+xlab(paste("Dim.",dims[1])) + ylab(paste("Dim.",dims[2]))  
    #out = a
    out$map=a
    # print(a)
  }
  if(what[1]==TRUE && what[2]==TRUE ){
    
    if (length(x$size) != 1)
    {
      names(group_df)[3] = "gr"
      levels(obs_df$gr) = levels(group_df$gr)
    }
    
    if(nrow(att_df)>=25){
      decr=(nrow(att_df)-25)*(1/250)
      mysize=5 * (1-decr)
      mysize=max(2,mysize)
    }else{mysize=5}
    
    a=ggplot(data=att_df,aes(x=d1,y=d2))+xlim(xallmin,xallmax)+ylim(yallmin,yallmax)
    
    a=a+geom_point(data=obs_df,aes(x=d1,y=d2,colour=gr,shape=gr,alpha=.4),size=1,na.rm = TRUE)+theme_bw()
    a=a+theme(legend.position="none",axis.text.x = element_blank(),axis.text.y = element_blank())+xlab("")+ylab("")
    a=a+geom_vline(xintercept=0)+geom_hline(yintercept=0)
    if (length(x$size) != 1)
    {
      a=a+geom_point(data=group_df,colour="black",aes(x=d1,y=d2,shape=gr),na.rm = TRUE)+theme(legend.position="none",axis.text.x = element_blank(),axis.text.y = element_blank())
      a=a+geom_text_repel(data=group_df,colour="black",aes(label=gr))
    }
    # 
    a = a + geom_point(data=att_df,aes(x=d1,y=d2),alpha=.5,size=.25,na.rm=TRUE) #+theme_bw()+xlab("")+ylab("")
    a=a+geom_text_repel(data=subset(att_df,act=="outer"),aes( label = attnam),size=mysize,segment.size = 0.1)
    a=a+geom_text_repel(data=subset(att_df,act!="outer"),aes( label = attnam),size=mysize*.8,segment.size = 0.01)
    a=a+geom_vline(xintercept=0)+geom_hline(yintercept=0)
    a=a+xlab(paste("Dim.",dims[1])) + ylab(paste("Dim.",dims[2]))  
    out = list()
    out$map = a
     # print(a)
  }
  print(a)
  if(cludesc==TRUE){
    csize = round((table(x$cluster)/sum(table(x$cluster)))*100,digits=1)
    cnames=paste("C",1:K,sep="")
    cnm=paste(cnames,": ",csize,"%",sep="")
    
    if (topstdres > length(attlabs)) {
      topstdres = length(attlabs)
    }
    ffew = topstdres 
    
    myminx = -10
    mymaxx = 10
    TopplotGroups=outOfIndependence(x$odata,x$cluster,attlabs,firstfew=ffew,textSize=4,segSize=4,minx=myminx,maxx=mymaxx)
    
    plotGroups=outOfIndependence(x$odata,x$cluster,nolabs=T,attlabs,fixmarg=F,textSize=1.5,segSize=1.5,minx=-2.5,maxx=2.5)
    
    for(jjj in 1:K){
      TopplotGroups$G[[jjj]]=TopplotGroups$G[[jjj]]+theme_bw()+ggtitle(cnm[jjj])
      
      if (subplot == TRUE) {
        out$stdres = TopplotGroups$G
         print(TopplotGroups$G[[jjj]])
         print(plotGroups$G[[jjj]], vp=viewport(.15, .18, .3, .35))
      }else{print(TopplotGroups$G[[jjj]])}
      # print(TopplotGroups$G[[jjj]])
    }
   
  }  
  
  invisible(out)
  
}
#}
