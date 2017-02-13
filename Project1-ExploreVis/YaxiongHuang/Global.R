library(tidyr)
library(dplyr)
# setwd("/Users/tommyhuang/Desktop")

data<-read.csv("./data/UPdatedNYCLeadingCauseData.csv",stringsAsFactors = F)
HealthData<-filter(data,Leading.Cause=="All Other Causes", Year == '2007', Sex == 'F')

#Heart Disease Health Indicators data
HD1<-gather(HealthData,key="MortalityType",value="Mortality",c(35,37,39,41)) #Mortality
HD1<-HD1[,c(4,40,41)]
HD1[HD1$MortalityType=='HeartDiseaseMortality',]$MortalityType<-'Heart Disease Mortality'
HD1[HD1$MortalityType=='CerebrovascularDiseaseStrokeMortality',]$MortalityType<-'Cerebrovascular Disease Stroke Mortality'
HD1[HD1$MortalityType=='CoronaryHeartDiseaseMortality',]$MortalityType<-'Coronary Heart Disease Mortality'
HD1[HD1$MortalityType=='CongestiveHeartFailureMortality',]$MortalityType<-'Congestive Heart Failure Mortality'
HD2<-gather(HealthData,key="MortalityType",value="Mortality",c(36,38,40,42)) #hospitalizations
HD2<-HD2[,c(4,40,41)]
HD2[HD2$MortalityType=='HeartDiseaseHospitalizations',]$MortalityType<-'Heart Disease Hospitalizations'
HD2[HD2$MortalityType=='CerebrovascularDiseaseStrokeHospitalizations',]$MortalityType<-'Cerebrovascular Disease Stroke Hospitalizations'
HD2[HD2$MortalityType=='CoronaryHeartDiseaseHospitalizations',]$MortalityType<-'Coronary Heart Disease Hospitalizations'
HD2[HD2$MortalityType=='CongestiveHeartFailureHospitalizations',]$MortalityType<-'Congestive Heart Failure Hospitalizations'

#Injury-Related Indicators
IR1<-gather(HealthData,key="MortalityType",value="Mortality",c(12,13))
IR1<-IR1[,c(4,42,43)]
IR1[IR1$MortalityType=='MotorVehicleMortality',]$MortalityType<-'Motor Vehicle Mortality'
IR1[IR1$MortalityType=="UnintentionalInjuryMortality",]$MortalityType<-"Unintentional Injury Mortality"
IR2<-gather(HealthData,key="MortalityType",value="Mortality",c(14,15,16))
IR2<-IR2[,c(4,41,42)]
IR2[IR2$MortalityType=="UnintentionalInjuryHospitalizations",]$MortalityType<-"Unintentional Injury Hospitalizations"
IR2[IR2$MortalityType=="PoisoningHospitalizations",]$MortalityType<-"Poisoning Hospitalizations"
IR2[IR2$MortalityType=="FallHospitalizations",]$MortalityType<-"Fall Hospitalizations Aged 65+"

#Respiratory Disease Indicators
RD1<-gather(HealthData,key="MortalityType",value="Mortality",19)
RD1<-RD1[,c(4,43,44)]
RD1$MortalityType<-"Chronic Lower Respiratory Disease Mortality"
RD2<-gather(HealthData,key="MortalityType",value="Mortality",c(17,18,20))
RD2<-RD2[,c(4,41,42)]
RD2[RD2$MortalityType=="AsthmaHospitalizations",]$MortalityType<-"Asthma Hospitalizations"
RD2[RD2$MortalityType=="AsthmaHospitalizationsBelow17",]$MortalityType<-"Asthma Hospitalizations Aged Below 17"
RD2[RD2$MortalityType=="ChronicLowerRespiratoryDiseaseHospitalizations",]$MortalityType<-"Chronic Lower Respiratory Disease Hospitalizations"

#Substance Abuse and Mental Health-Related Indicators
SAM1<-gather(HealthData,key="MortalityType",value="Mortality",34)
SAM1<-SAM1[,c(4,43,44)]
SAM1$MortalityType<-"Suicide Mortality"
SAM2<-gather(HealthData,key="MortalityType",value="Mortality",33)
SAM2<-SAM2[,c(4,43,44)]
SAM2$MortalityType<-"Drug Related Hospitalizations"

#Diabetes Indicators
DI1<-gather(HealthData,key="MortalityType",value="Mortality",21)
DI1<-DI1[,c(4,43,44)]
DI1$MortalityType<-"Diabetes Mortality"
DI2<-gather(HealthData,key="MortalityType",value="Mortality",22:25)
DI2<-DI2[,c(4,40,41)]
DI2[DI2$MortalityType=="DiabetesAnyDiagnosisHospitalizations",]$MortalityType<-"Diabetes Any Diagnosis Hospitalizations"
DI2[DI2$MortalityType=="DiabetesShortTermComplicationsHospitalizations",]$MortalityType<-"Diabetes Short Term Complications Hospitalizations 6-17"
DI2[DI2$MortalityType=="DiabetesPrimaryDiagnosisHospitalizations",]$MortalityType<-"Diabetes Primary Diagnosis Hospitalizations"
DI2[DI2$MortalityType=="DiabetesShortTermComplicationsHospitalizations18Up",]$MortalityType<-"Diabetes Short Term Complications Hospitalizations 18+"

#Cancer Indicators
CI1<-gather(HealthData,key="MortalityType",value="Mortality",c(26,28,30,32))
CI1<-CI1[,c(4,40,41)]
CI1[CI1$MortalityType=="LungCancerIncidence",]$MortalityType<-"Lung Cancer Incidence"
CI1[CI1$MortalityType=="ColorectalCancerIncidence",]$MortalityType<-"Colorectal Cancer Incidence"
CI1[CI1$MortalityType=="CervicalCancerIncidence",]$MortalityType<-"Cervical Cancer Incidence"
CI1[CI1$MortalityType=="FemaleLateStageBreastCancerIncidence",]$MortalityType<-"Female Late Stage Breast Cancer Incidence"
CI2<-gather(HealthData,key="MortalityType",value="Mortality",c(27,29,31))
CI2<-CI2[,c(4,41,42)]
CI2[CI2$MortalityType=="ColorectalCancerMortality",]$MortalityType<-"Colorectal Cancer Mortality"
CI2[CI2$MortalityType=="FemaleBreastCancerMortality",]$MortalityType<-"Female Breast Cancer Mortality"
CI2[CI2$MortalityType=="CervixUteriCancerMortality",]$MortalityType<-"Cervix Uteri Cancer Mortality"

#Birth-Related Indicators
BI<-gather(HealthData,key="MortalityType",value="Mortality",11)
BI<-BI[,c(4,43,44)]
BI$MortalityType<-"Infant Mortality"





