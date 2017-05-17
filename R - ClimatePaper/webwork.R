############################## script to batch download netcdfs from NOAA's Climate Change Web Portal

######working with rselenium https://cran.r-project.org/web/packages/RSelenium/RSelenium.pdf
# 0. download rselenium standalone server.jar : http://www.seleniumhq.org/download/
# this code is supposed to do it automatically but d.n. work for me
#   unlink(system.file("bin", package = "RSelenium"), recursive = T) ##d.n. download, had to go get and maunally download
#   checkForServer()
# 1. put .jar in wd
# 2. put .jar in C:\Users\Heather.Welch\Documents\R\win-library\3.2
# 3. double click in .jar in C:\Users\Heather.Welch\Documents\R\win-library\3.2
# 4. checkForServer()
# 5. start server()
# 6. define remote browser()

###################################### A. Get Selenium going
library(RSelenium)
library(RCurl) #loads automatically
library(RJSONIO) #loads automatically
library(XML)#loads automatically

setwd("F:/Scripts/R - ClimatePaper") 
#RSelenium::checkForServer()
checkForServer()
startServer()
#RSelenium::startServer()

######################################## B. Get Firefox going
mybrowser=remoteDriver$new()##defaults to firefox
url="http://www.esrl.noaa.gov/psd/ipcc/ocn/"
mybrowser$open(silent=TRUE)
mybrowser$navigate(url)

########################## C. Fill out all the dropdowns by right clicking on the element and selecting inspect element. xpath searches the webpage html to find the element
###click selects whatever option you've told it to find
option <- mybrowser$findElement(using = 'xpath', "//*/option[@value = 'ENSMN']")
option$clickElement()
option <- mybrowser$findElement(using = 'xpath', "//*/option[@value = 'tos']")
option$clickElement()
option <- mybrowser$findElement(using = 'xpath', "//*/option[@value = 'anom']")
option$clickElement()
option <- mybrowser$findElement(using = 'xpath', "//*/option[@value = 'JAS']")
option$clickElement()
option <- mybrowser$findElement(using = 'xpath', "//*/option[@value = '2050-2099']")
option$clickElement()
option <- mybrowser$findElement(using = 'xpath', "//*/option[@value = 'CUSTOM']")
option$clickElement()
option <- mybrowser$findElement(using = 'xpath', "//*/input[@id = 'area_north']")
option$sendKeysToElement(list("49","\uE007"))
option <- mybrowser$findElement(using = 'xpath', "//*/input[@id = 'area_east']")
option$sendKeysToElement(list("-64","\uE007"))
option <- mybrowser$findElement(using = 'xpath', "//*/input[@id = 'area_south']")
option$sendKeysToElement(list("22","\uE007"))
option <- mybrowser$findElement(using = 'xpath', "//*/input[@id = 'area_west']")
option$sendKeysToElement(list("-86","\uE007"))
option <- mybrowser$findElement(using = 'xpath', "//*/input[@value = 'Download Data']")
option$clickElement()
{
mybrowser$setImplicitWaitTimeout(milliseconds=20000) ###make it wait for awhile until element appears, explicit waiting
option <- mybrowser$findElement(using = 'xpath', "//*/span[@class= 'download_text']/parent::a")  #span is text inside an anchor, anchors contain the downloadable data. finds the span text, redirects to downloadable anchor
}
option$clickElement()
###########THIS SHIT FUCKING WORKS!!

########################################## D. now to make it batchable so it downloads all at once.
variables=c("tos","sos","ph","intpp","chl","temp.bot300","salt.bot300","o2") #define variables, in order: sst, sss, ph, prim prod, chl, bottom temp, bottom sal, sea surface oxygen
period=c("2006-2055","2050-2099")
season=c("JFM","AMJ","JAS","OND")
for (per in period){
  for (sea in season){
    for (var in variables){
      mybrowser$navigate(url) #will need to open a fresh browser each time to reset all windows 
      {
      mybrowser$setImplicitWaitTimeout(milliseconds=20000) ##have it wait until browser window loads
      option <- mybrowser$findElement(using = 'xpath', "//*/option[@value = 'ENSMN']") ###model variable
      }
      option$clickElement()
      string=paste("//*/option[@value= '",var,"']",sep="")
      option <- mybrowser$findElement(using = 'xpath', string) ###field variable
      option$clickElement()
      option <- mybrowser$findElement(using = 'xpath', "//*/option[@value = 'anom']") ###staistic variable
      option$clickElement()
      string2=paste("//*/option[@value= '",sea,"']",sep="")
      option <- mybrowser$findElement(using = 'xpath', string2) ###season variable
      option$clickElement()
      string3=paste("//*/option[@value= '",per,"']",sep="")
      option <- mybrowser$findElement(using = 'xpath', string3) ###period variable
      option$clickElement()
      option <- mybrowser$findElement(using = 'xpath', "//*/option[@value = 'CUSTOM']") ###map region variable
      option$clickElement()
      option <- mybrowser$findElement(using = 'xpath', "//*/input[@id = 'area_north']")
      option$sendKeysToElement(list("49","\uE007"))
      option <- mybrowser$findElement(using = 'xpath', "//*/input[@id = 'area_east']")
      option$sendKeysToElement(list("-64","\uE007"))
      option <- mybrowser$findElement(using = 'xpath', "//*/input[@id = 'area_south']")
      option$sendKeysToElement(list("22","\uE007"))
      option <- mybrowser$findElement(using = 'xpath', "//*/input[@id = 'area_west']")
      option$sendKeysToElement(list("-86","\uE007"))
      option <- mybrowser$findElement(using = 'xpath', "//*/input[@value = 'Download Data']")
      option$clickElement()
      {
      mybrowser$setImplicitWaitTimeout(milliseconds=20000) ###make it wait for awhile until element appears, explicit waiting
      option <- mybrowser$findElement(using = 'xpath', "//*/span[@class= 'download_text']/parent::a")
      }
      option$clickElement() ##downloads the netcdf ####web stuff complete
      option <- mybrowser$findElement(using = 'xpath', "//*/span[@class= 'download_text']/parent::a") ###now find file name
      href=option$getElementAttribute("href") #grab the href...unique for each netcdf
      href_st=as.character(href)
      name=gsub("http://www.esrl.noaa.gov/psd/tmp/ipcc/","",href_st)
      old=paste("C:/Users/Heather.Welch/Downloads/",name,sep="")
      new=paste("C:/Users/Heather.Welch/Downloads/",var,"_",sea,"_",per,".nc",sep="")
      print(new)
      file.rename(old,new) ##give the downloaded file a new name based on whats inside so i don't have to figure that out later
    }
  }
}





############################################### extra bits and pieces of code
Sys.sleep(10) ##run this if things mess up, kinda a reset
#mybrowser$open()
#mybrowser=remoteDriver(brownserName="chrome")
#import org.openqa.selenium.firefox.FirefoxDriver
#system("java -jar selenium-server-standalone-2.44.0.jar") ###this is the wrong version of selenium!
#npm install --save-dev selenium-server-standalone-jar

# webElem <- mybrowser$findElement(using = 'css selector', ".left_column #model") ##find css selectors by using selectorgadget and clicking
# webElem <- mybrowser$findElement(using = 'id', value="model") 
# webElem <- mybrowser$findElement(using = 'class', "select_widget")
# webElem$getElementAttribute("model")
# 
# searchID<-'//*[@id="ctl00_foPageContent_SearchButton"]'
# webElem<-mybrowser$findElement(value = searchID)
# 
# library("rvest")
# html=read_html("http://www.esrl.noaa.gov/psd/ipcc/ocn/")
# model=html_nodes(html,".left_column #model ")
# html_text(model)

###messedup,workaroudn
unlink(system.file("bin", package = "RSelenium"), recursive = T) ##d.n. download, had to go get and maunally download
checkForServer()

####downloading NETCDFS from the internet
download.file("http://esrl.noaa.gov/psd/tmp/ipcc/myplot.32227.1459263508.96.nc",destfile = "C:/Users/Heather.Welch/Downloads/trial3.nc",mode="wb")

library(data.table)
mydat=fread("http://esrl.noaa.gov/psd/tmp/ipcc/myplot.32227.1459263508.96.nc")

######scraping webpages with r DIDNOT WORK
# install.packages(c("RCurl", "XML"))
# options(pkgType="source")
# setRepositories()
# install.packages('RHTMLForms')
# install.packages("RHTMLForms", repos = "http://www.omegahat.org/R", type = "source")
# install.packages("RHTMLForms", repos = "http://www.omegahat.org/R")

library("XML")
library("rvest")
noaa=read_html("http://www.esrl.noaa.gov/psd/ipcc/ocn/")


library("scrapeR")
pageSoure=scrape(url="http://www.esrl.noaa.gov/psd/ipcc/ocn/",headers=TRUE,parse=FALSE)
for(attributes(PageSoure)){
  page=scrape(object="pageSoure")
  xpathSApply(page,"//table//td/a",xmlValue)
}

web_page=readLines("http://www.esrl.noaa.gov/psd/ipcc/ocn/")
author_lines <- web_page[grep("<I>", web_page)]
web=getURL("http://www.esrl.noaa.gov/psd/ipcc/ocn/",ssl.verifypeer=FALSE)
web_parsed=htmlTreeParse(web)