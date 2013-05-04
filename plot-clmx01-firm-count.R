
## Prep workspace
rm(list=ls())
library(foreign)
library(grid)
library(plyr)
library(ggplot2)
library(tikzDevice)
library(reshape)
library(vars)


scl.str.DAT_DIR  <- "~/Dropbox/research/trading_on_coincidences/data/"
scl.str.DAT_NAME <- "clmx01-observations-per-month.csv"
scl.str.FIG_DIR  <- "~/Dropbox/research/trading_on_coincidences/figures/"










## Load CLMX01 firm count data
mat.dfm.CLMX01        <- read.csv(paste(scl.str.DAT_DIR, scl.str.DAT_NAME, sep = ""), stringsAsFactors = FALSE)
mat.dfm.CLMX01$t      <- mat.dfm.CLMX01$year + (mat.dfm.CLMX01$month - 1)/12
mat.dfm.CLMX01        <- mat.dfm.CLMX01[, names(mat.dfm.CLMX01) %in% c("indAbrv", "obsPerMonth", "t")]
names(mat.dfm.CLMX01) <- c("ind", "N", "t")










## Plot firm count time series
mat.dfm.PLOT        <- mat.dfm.CLMX01

theme_set(theme_bw())

scl.str.RAW_FILE <- 'clmx02-firm-count-per-industry'
scl.str.TEX_FILE <- paste(scl.str.RAW_FILE,'.tex',sep='')
scl.str.PDF_FILE <- paste(scl.str.RAW_FILE,'.pdf',sep='')
scl.str.PNG_FILE <- paste(scl.str.RAW_FILE,'.png',sep='')
scl.str.AUX_FILE <- paste(scl.str.RAW_FILE,'.aux',sep='')
scl.str.LOG_FILE <- paste(scl.str.RAW_FILE,'.log',sep='')

tikz(file = scl.str.TEX_FILE, height = 11, width = 24, standAlone=TRUE)

obj.gg2.PLOT <- ggplot()
obj.gg2.PLOT <- obj.gg2.PLOT + geom_path(data = mat.dfm.PLOT,
                                         aes(x      = t, 
                                             y      = N,
                                             group  = ind
                                             ),
                                         size     = 1.25
                                         )
obj.gg2.PLOT <- obj.gg2.PLOT + facet_wrap(~ind, ncol = 7)
obj.gg2.PLOT <- obj.gg2.PLOT + ylab('Number of Firms')
obj.gg2.PLOT <- obj.gg2.PLOT + xlab('')
obj.gg2.PLOT <- obj.gg2.PLOT + opts(legend.position = "none")


print(obj.gg2.PLOT)
dev.off()

system(paste('pdflatex', file.path(scl.str.TEX_FILE)), ignore.stdout = TRUE)
system(paste('convert -density 450', file.path(scl.str.PDF_FILE), ' ', file.path(scl.str.PNG_FILE)))
system(paste('mv ', scl.str.PNG_FILE, ' ', scl.str.FIG_DIR, sep = ''))
system(paste('rm ', scl.str.TEX_FILE, sep = ''))
system(paste('mv ', scl.str.PDF_FILE, ' ', scl.str.FIG_DIR, sep = ''))
system(paste('rm ', scl.str.AUX_FILE, sep = ''))
system(paste('rm ', scl.str.LOG_FILE, sep = ''))






mat.dfm.PLOT        <- ddply(mat.dfm.CLMX01,
                             c("t"),
                             function(X)sum(X$N)
                             )
names(mat.dfm.PLOT) <- c("t", "N")
asdasd;

theme_set(theme_bw())

scl.str.RAW_FILE <- 'clmx02-firm-count-total'
scl.str.TEX_FILE <- paste(scl.str.RAW_FILE,'.tex',sep='')
scl.str.PDF_FILE <- paste(scl.str.RAW_FILE,'.pdf',sep='')
scl.str.PNG_FILE <- paste(scl.str.RAW_FILE,'.png',sep='')
scl.str.AUX_FILE <- paste(scl.str.RAW_FILE,'.aux',sep='')
scl.str.LOG_FILE <- paste(scl.str.RAW_FILE,'.log',sep='')

tikz(file = scl.str.TEX_FILE, height = 11, width = 24, standAlone=TRUE)

obj.gg2.PLOT <- ggplot()
obj.gg2.PLOT <- obj.gg2.PLOT + geom_path(data = mat.dfm.PLOT,
                                         aes(x      = t, 
                                             y      = N,
                                             group  = ind
                                             ),
                                         size     = 1.25
                                         )
obj.gg2.PLOT <- obj.gg2.PLOT + facet_wrap(~variable, ncol = 7)
obj.gg2.PLOT <- obj.gg2.PLOT + ylab('Number of Firms')
obj.gg2.PLOT <- obj.gg2.PLOT + xlab('')
obj.gg2.PLOT <- obj.gg2.PLOT + opts(legend.position = "none")


print(obj.gg2.PLOT)
dev.off()

system(paste('pdflatex', file.path(scl.str.TEX_FILE)), ignore.stdout = TRUE)
system(paste('convert -density 450', file.path(scl.str.PDF_FILE), ' ', file.path(scl.str.PNG_FILE)))
system(paste('mv ', scl.str.PNG_FILE, ' ', scl.str.FIG_DIR, sep = ''))
system(paste('rm ', scl.str.TEX_FILE, sep = ''))
system(paste('mv ', scl.str.PDF_FILE, ' ', scl.str.FIG_DIR, sep = ''))
system(paste('rm ', scl.str.AUX_FILE, sep = ''))
system(paste('rm ', scl.str.LOG_FILE, sep = ''))







