## 来源 https://blog.csdn.net/weixin_64520386/article/details/135521405

packages <- c('rvest', 'httr', 'jsonlite', 'dplyr', 'data.table', 'tidyverse')
for(pkg in packages) {
  if(!require(pkg, character.only = TRUE)) {
    install.packages(pkg, repos='https://cran.r-project.org')
    library(pkg, character.only = TRUE)
  }
}

# 获取当前脚本所在的目录路径
script_path <- dirname(normalizePath(sys.frame(1)$ofile))
setwd(script_path)
# 设置阈值
obThresholdValue = 30
dlThresholdValue = 0.18
 
# 填写药名称（可填写多个）
names <- c(
  'Mori Cortex'
)
 
# 填写药对应的链接，与上面填写的药名称顺序一致
urls <- c(
    'https://www.tcmsp-e.com/tcmspsearch.php?qr=Mori%20Cortex&qsr=herb_en_name&token=f357e909de428e8afa61cf7504960414'
)
 
all_drug_target <- tibble(Drug=NA,MOL_ID=NA,molecule_name=NA,target_name=NA)
 
num <- 1
for (url in urls) {
  name <- names[num]
  print(name)
  num <- num + 1
  web <- read_html(GET(url,encoding="UTF-8", config(ssl_verifypeer = FALSE)))
 
  tcmsp <- web %>% html_elements("script") %>% html_text()
  test1 <- str_extract_all(tcmsp,"data:\\s\\[.*\\]")
  test2 <- unlist(test1[12])
  if (length(test2) == 0) {
    warning(paste("未提取到数据，URL: ", url))
    next
  }
  drug_m <- str_replace(test2[1], "data:","") %>% fromJSON(simplifyVector = TRUE) %>% mutate(across(c(ob, dl), as.numeric)) %>% filter(ob >= obThresholdValue & dl >= dlThresholdValue)
  drug_t <- str_replace(test2[2], "data:","") %>% fromJSON(simplifyVector = TRUE) %>% semi_join(drug_m, by = "MOL_ID") %>% tibble() %>% add_column(Drug = name, .before = 'molecule_ID') %>% select(Drug, MOL_ID, molecule_name, target_name)
  all_drug_target <- all_drug_target %>% add_row(drug_t)
}
 
all_drug_target <- all_drug_target %>% filter(!is.na(Drug) & !is.na(MOL_ID) & !is.na(molecule_name) & !is.na(target_name)) %>% distinct(target_name, molecule_name, Drug, MOL_ID, .keep_all = TRUE)
 
write.table(all_drug_target, file="AllDrugTarget.txt", sep="\t", row.names=FALSE, quote = FALSE)
