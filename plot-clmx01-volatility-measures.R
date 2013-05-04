
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
scl.str.DAT_NAME <- "clmx01-variance-decomposition-time-series.csv"
scl.str.FIG_DIR  <- "~/Dropbox/research/trading_on_coincidences/figures/"










## Load CLMX01 volatility data
mat.dfm.CLMX01   <- read.csv(paste(scl.str.DAT_DIR, scl.str.DAT_NAME, sep = ""), stringsAsFactors = FALSE)
mat.dfm.CLMX01$t <- mat.dfm.CLMX01$year + (mat.dfm.CLMX01$month - 1)/12







## Estimate vector autoregression
mat.dfm.VAR         <- mat.dfm.CLMX01[mat.dfm.CLMX01$t < 1998, names(mat.dfm.CLMX01) %in% c("mktVar", "indVar", "firmVar")]
mat.dfm.VAR$mktVar  <- mat.dfm.VAR$mktVar * 12 * 1.75
mat.dfm.VAR$indVar  <- mat.dfm.VAR$indVar * 12 * 1.75
mat.dfm.VAR$firmVar <- mat.dfm.VAR$firmVar * 12 * 1.75
cor(mat.dfm.VAR)
obj.var.RESULTS     <- VAR(mat.dfm.VAR, p = 1, type = "const")
summary(obj.var.RESULTS)
### plot(obj.var.RESULTS)








## Plot CLMX01 market volatility
mat.dfm.PLOT        <- mat.dfm.CLMX01[, names(mat.dfm.CLMX01) %in% c("t", "mktVar")]
names(mat.dfm.PLOT) <- c("Annualized Market Variance: $\\hat{\\sigma}_{\\mathrm{Mkt},t}^2$",
                         "t"
                         )
mat.dfm.PLOT        <- melt(mat.dfm.PLOT, c("t"))

theme_set(theme_bw())

scl.str.RAW_FILE <- 'clmx02-market-volatility-measure'
scl.str.TEX_FILE <- paste(scl.str.RAW_FILE,'.tex',sep='')
scl.str.PDF_FILE <- paste(scl.str.RAW_FILE,'.pdf',sep='')
scl.str.PNG_FILE <- paste(scl.str.RAW_FILE,'.png',sep='')
scl.str.AUX_FILE <- paste(scl.str.RAW_FILE,'.aux',sep='')
scl.str.LOG_FILE <- paste(scl.str.RAW_FILE,'.log',sep='')

tikz(file = scl.str.TEX_FILE, height = 4, width = 7, standAlone=TRUE)

obj.gg2.PLOT <- ggplot()
obj.gg2.PLOT <- obj.gg2.PLOT + geom_path(data = mat.dfm.PLOT[mat.dfm.PLOT$t < 1998,],
                                         aes(x      = t, 
                                             y      = value * 12 * 1.75,
                                             group  = variable,
                                             colour = variable
                                             ),
                                         size     = 1.25
                                         )
obj.gg2.PLOT <- obj.gg2.PLOT + coord_cartesian(ylim = c(0, 0.01))
obj.gg2.PLOT <- obj.gg2.PLOT + facet_wrap(~variable, ncol = 1)
obj.gg2.PLOT <- obj.gg2.PLOT + ylab('')
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


## Plot CLMX01 industry level volatility
mat.dfm.PLOT        <- mat.dfm.CLMX01[, names(mat.dfm.CLMX01) %in% c("t", "indVar")]
names(mat.dfm.PLOT) <- c("Annualized Industry Variance: $\\hat{\\sigma}_{\\mathrm{Ind},t}^2$",
                         "t"
                         )
mat.dfm.PLOT        <- melt(mat.dfm.PLOT, c("t"))

theme_set(theme_bw())

scl.str.RAW_FILE <- 'clmx02-industry-volatility-measure'
scl.str.TEX_FILE <- paste(scl.str.RAW_FILE,'.tex',sep='')
scl.str.PDF_FILE <- paste(scl.str.RAW_FILE,'.pdf',sep='')
scl.str.PNG_FILE <- paste(scl.str.RAW_FILE,'.png',sep='')
scl.str.AUX_FILE <- paste(scl.str.RAW_FILE,'.aux',sep='')
scl.str.LOG_FILE <- paste(scl.str.RAW_FILE,'.log',sep='')

tikz(file = scl.str.TEX_FILE, height = 4, width = 7, standAlone=TRUE)

obj.gg2.PLOT <- ggplot()
obj.gg2.PLOT <- obj.gg2.PLOT + geom_path(data = mat.dfm.PLOT[mat.dfm.PLOT$t < 1998,],
                                         aes(x      = t, 
                                             y      = value * 12 * 1.75,
                                             group  = variable,
                                             colour = variable
                                             ),
                                         size     = 1.25
                                         )
obj.gg2.PLOT <- obj.gg2.PLOT + coord_cartesian(ylim = c(0, 0.007))
obj.gg2.PLOT <- obj.gg2.PLOT + facet_wrap(~variable, ncol = 1)
obj.gg2.PLOT <- obj.gg2.PLOT + ylab('')
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



## Plot CLMX01 firm level volatility
mat.dfm.PLOT        <- mat.dfm.CLMX01[, names(mat.dfm.CLMX01) %in% c("t", "firmVar")]
names(mat.dfm.PLOT) <- c("Annualized Firm Variance: $\\hat{\\sigma}_{\\mathrm{Firm},t}^2$",
                         "t"
                         )
mat.dfm.PLOT        <- melt(mat.dfm.PLOT, c("t"))

theme_set(theme_bw())

scl.str.RAW_FILE <- 'clmx02-firmLevel-volatility-measure'
scl.str.TEX_FILE <- paste(scl.str.RAW_FILE,'.tex',sep='')
scl.str.PDF_FILE <- paste(scl.str.RAW_FILE,'.pdf',sep='')
scl.str.PNG_FILE <- paste(scl.str.RAW_FILE,'.png',sep='')
scl.str.AUX_FILE <- paste(scl.str.RAW_FILE,'.aux',sep='')
scl.str.LOG_FILE <- paste(scl.str.RAW_FILE,'.log',sep='')

tikz(file = scl.str.TEX_FILE, height = 4, width = 7, standAlone=TRUE)

obj.gg2.PLOT <- ggplot()
obj.gg2.PLOT <- obj.gg2.PLOT + geom_path(data = mat.dfm.PLOT[mat.dfm.PLOT$t < 1998,],
                                         aes(x      = t, 
                                             y      = value * 12 * 1.75,
                                             group  = variable,
                                             colour = variable
                                             ),
                                         size     = 1.25
                                         )
obj.gg2.PLOT <- obj.gg2.PLOT + coord_cartesian(ylim = c(0, 0.02))
obj.gg2.PLOT <- obj.gg2.PLOT + facet_wrap(~variable, ncol = 1)
obj.gg2.PLOT <- obj.gg2.PLOT + ylab('')
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


## PLot updated CLMX01 volatility measures
mat.dfm.PLOT        <- mat.dfm.CLMX01[, names(mat.dfm.CLMX01) %in% c("t", "mktVar", "indVar", "firmVar")]
names(mat.dfm.PLOT) <- c("Annualized Market Variance: $\\hat{\\sigma}_{\\mathrm{Mkt},t}^2$",
                         "Annualized Industry Variance: $\\hat{\\sigma}_{\\mathrm{Ind},t}^2$",
                         "Annualized Firm Variance: $\\hat{\\sigma}_{\\mathrm{Firm},t}^2$",
                         "t"
                         )
mat.dfm.PLOT        <- melt(mat.dfm.PLOT, c("t"))

theme_set(theme_bw())

scl.str.RAW_FILE <- 'clmx02-updated-volatility-measures'
scl.str.TEX_FILE <- paste(scl.str.RAW_FILE,'.tex',sep='')
scl.str.PDF_FILE <- paste(scl.str.RAW_FILE,'.pdf',sep='')
scl.str.PNG_FILE <- paste(scl.str.RAW_FILE,'.png',sep='')
scl.str.AUX_FILE <- paste(scl.str.RAW_FILE,'.aux',sep='')
scl.str.LOG_FILE <- paste(scl.str.RAW_FILE,'.log',sep='')

tikz(file = scl.str.TEX_FILE, height = 5, width = 7, standAlone=TRUE)

obj.gg2.PLOT <- ggplot()
obj.gg2.PLOT <- obj.gg2.PLOT + geom_path(data = mat.dfm.PLOT,
                                         aes(x      = t, 
                                             y      = value * 12 * 1.75,
                                             group  = variable,
                                             colour = variable
                                             ),
                                         size     = 1.25
                                         )
obj.gg2.PLOT <- obj.gg2.PLOT + facet_wrap(~variable, ncol = 1, scales = "free_y")
obj.gg2.PLOT <- obj.gg2.PLOT + ylab('')
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












## Plot CLMX01 R2 time series
mat.dfm.PLOT    <- mat.dfm.CLMX01[mat.dfm.CLMX01$t < 1998, names(mat.dfm.CLMX01) %in% c("t", "mktVar", "indVar", "firmVar")]
mat.dfm.PLOT$R2 <- (mat.dfm.PLOT$mktVar + mat.dfm.PLOT$indVar)/(mat.dfm.PLOT$mktVar + mat.dfm.PLOT$indVar + mat.dfm.PLOT$mktVar + mat.dfm.PLOT$firmVar)
mat.dfm.PLOT$ma <- NA
for (r in 12:length(mat.dfm.PLOT$R2)) {
  mat.dfm.PLOT$ma[r] <- mean(mat.dfm.PLOT$R2[(r-11):r])
  
}
mat.dfm.PLOT        <- mat.dfm.PLOT[, names(mat.dfm.PLOT) %in% c("t", "ma")]
names(mat.dfm.PLOT) <- c("t", "$12$ Month Moving Average: $(\\hat{\\sigma}_{\\mathrm{Mkt},t}^2 + \\hat{\\sigma}_{\\mathrm{Ind},t}^2)/(\\hat{\\sigma}_{\\mathrm{Mkt},t}^2 + \\hat{\\sigma}_{\\mathrm{Ind},t}^2 + \\hat{\\sigma}_{\\mathrm{Firm},t}^2)$")
mat.dfm.PLOT        <- melt(mat.dfm.PLOT, c("t"))


theme_set(theme_bw())

scl.str.RAW_FILE <- 'clmx02-r2-series'
scl.str.TEX_FILE <- paste(scl.str.RAW_FILE,'.tex',sep='')
scl.str.PDF_FILE <- paste(scl.str.RAW_FILE,'.pdf',sep='')
scl.str.PNG_FILE <- paste(scl.str.RAW_FILE,'.png',sep='')
scl.str.AUX_FILE <- paste(scl.str.RAW_FILE,'.aux',sep='')
scl.str.LOG_FILE <- paste(scl.str.RAW_FILE,'.log',sep='')

tikz(file = scl.str.TEX_FILE, height = 4, width = 7, standAlone=TRUE)

obj.gg2.PLOT <- ggplot()
obj.gg2.PLOT <- obj.gg2.PLOT + geom_path(data = mat.dfm.PLOT,
                                         aes(x      = t, 
                                             y      = value,
                                             group  = variable,
                                             colour = variable
                                             ),
                                         size     = 1.25
                                         )
obj.gg2.PLOT <- obj.gg2.PLOT + facet_wrap(~variable, ncol = 1, scales = "free_y")
obj.gg2.PLOT <- obj.gg2.PLOT + ylab('')
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



## Plot updated CLMX01 R2 time series
mat.dfm.PLOT    <- mat.dfm.CLMX01[, names(mat.dfm.CLMX01) %in% c("t", "mktVar", "indVar", "firmVar")]
mat.dfm.PLOT$R2 <- (mat.dfm.PLOT$mktVar + mat.dfm.PLOT$indVar)/(mat.dfm.PLOT$mktVar + mat.dfm.PLOT$indVar + mat.dfm.PLOT$mktVar + mat.dfm.PLOT$firmVar)
mat.dfm.PLOT$ma <- NA
for (r in 12:length(mat.dfm.PLOT$R2)) {
  mat.dfm.PLOT$ma[r] <- mean(mat.dfm.PLOT$R2[(r-11):r])
  
}
mat.dfm.PLOT        <- mat.dfm.PLOT[, names(mat.dfm.PLOT) %in% c("t", "ma")]
names(mat.dfm.PLOT) <- c("t", "$12$ Month Moving Average: $(\\hat{\\sigma}_{\\mathrm{Mkt},t}^2 + \\hat{\\sigma}_{\\mathrm{Ind},t}^2)/(\\hat{\\sigma}_{\\mathrm{Mkt},t}^2 + \\hat{\\sigma}_{\\mathrm{Ind},t}^2 + \\hat{\\sigma}_{\\mathrm{Firm},t}^2)$")
mat.dfm.PLOT        <- melt(mat.dfm.PLOT, c("t"))


theme_set(theme_bw())

scl.str.RAW_FILE <- 'clmx02-updated-r2-series'
scl.str.TEX_FILE <- paste(scl.str.RAW_FILE,'.tex',sep='')
scl.str.PDF_FILE <- paste(scl.str.RAW_FILE,'.pdf',sep='')
scl.str.PNG_FILE <- paste(scl.str.RAW_FILE,'.png',sep='')
scl.str.AUX_FILE <- paste(scl.str.RAW_FILE,'.aux',sep='')
scl.str.LOG_FILE <- paste(scl.str.RAW_FILE,'.log',sep='')

tikz(file = scl.str.TEX_FILE, height = 4, width = 7, standAlone=TRUE)

obj.gg2.PLOT <- ggplot()
obj.gg2.PLOT <- obj.gg2.PLOT + geom_path(data = mat.dfm.PLOT,
                                         aes(x      = t, 
                                             y      = value,
                                             group  = variable,
                                             colour = variable
                                             ),
                                         size     = 1.25
                                         )
obj.gg2.PLOT <- obj.gg2.PLOT + facet_wrap(~variable, ncol = 1, scales = "free_y")
obj.gg2.PLOT <- obj.gg2.PLOT + ylab('')
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









