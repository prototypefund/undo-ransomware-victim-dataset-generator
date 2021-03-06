library(RColorBrewer)

files=read.table('temp.psv',sep='|',header=T)
labels=c(round(10^(0:29/10)),
	paste(round(10^(0:9/10), 1), 'k', sep=''),
	paste(round(10^(10:29/10)), 'k', sep=''),
	paste(round(10^(0:9/10), 1), 'M', sep=''),
	paste(round(10^(10:29/10)), 'M', sep=''),
	paste(round(10^(0:9/10), 1), 'G', sep=''),
	paste(round(10^(10:19/10)), 'G', sep=''))
# colors=brewer.pal(8,'Set1') but without yellow
colors=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf')
pdf('temp.pdf', 20, 14)

mkplot = function(levels, title, range=c(20,73)) {
	maxk = 0
	for (level in levels) {
		segment = files[files$ext==level,]
		maxk = max(segment$count, maxk)
	}
	maxk = maxk / 1000
	#plot(c(0,105), c(0, 1000*maxk), type='n', axes=F, xlab='filesize', ylab='count')
	# usable range: 100 bytes to ~20MB. there's a long tail with a few huge files
	plot(range, c(0, 1000*maxk), type='n', axes=F, xlab='filesize', ylab='count')

	axis(1, 0:109, labels=labels, las=3)
	abline(v=10*log10(10^(0:10)), col='#cccccc')
	temp = merge(2:9, 10^(0:10), by=NULL)
	abline(v=10*log10(temp$x*temp$y), lty=2, col='#cccccc')

	axis(2, at=1000*0:maxk, labels=paste(0:maxk, 'k', sep=''), las=2)
	abline(h=1000*0:maxk, col='#cccccc')
	abline(h=0:10 * 100, col='#cccccc', lty=2)

	totalCount = 0
	totalSize = 0
	x = 0
	labels = c()
	for (level in levels) {
		segment = files[files$ext==level,]
		col = colors[1 + x %% length(colors)]
		lines(segment$dbb, segment$count, type='l', col=col)
		nonzero = segment[segment$count > 0,]
		points(nonzero$dbb, nonzero$count, type='p', col=col, pch=floor(x/length(colors)) + 1)
		x = x + 1
		count = sum(segment$count)
		size = round(sum(10^(segment$dbb / 10) * segment$count) / 1000000)
		labels = c(labels, paste(level, ' (', count, ' files, ', size, ' MB)', sep=''))
		totalCount = totalCount + count
		totalSize = totalSize + size
	}
	title(main=paste(title, ' (', totalCount, ' files, ', totalSize, ' MB)', sep=''))
	legend(range[2] - 8, 1000 * maxk, labels, col=colors[1 + 0:x %% length(colors)], lty=1, pch=floor(0:x/length(colors)) + 1)
}

mkplot(levels(files$ext), 'all files (except prefiltered)')
mkplot(c('doc','docx','odt','rtf','xls','xlsx','ods','csv','ppt','pptx','odp'), '"productivity" (office) files')
mkplot(c('doc','docx','odt','rtf'), '"productivity" (office) files: word processor')
mkplot(c('xls','xlsx','ods'), '"productivity" (office) files: spreadsheets')
mkplot(c('ppt','pptx','odp'), '"productivity" (office) files: presentations', c(43, 90))
mkplot(c('txt','md','tex','csv','xml','html'), 'plaintext office-like formats')
mkplot(c('pdf','ps','jpg','png','bmp','svg','tif'), 'images, PDFs and likely scanned stuff')
mkplot(c('zip','tgz','rar'), 'archives', c(30, 105))
mkplot(c('m4a','mp3','ogg','wav','mp4','mts','ogv','webm'), 'media files', c(40, 95))
mkplot(c('html','js','css','gif','php','png','svg'), 'curiosities: saved websites and probable website resources', c(17, 60))
mkplot(c('c','py','java'), 'curiosities: source code')

# select sum(count) as count, dbb, 'all' as ext from files
# where ext <> '(unidentified)' group by dbb
files = files[files$ext != '(unidentified)',]
files = aggregate(files$count, list(dbb=files$dbb), sum)
colnames(files) = c('dbb','count')
files$ext = c('all')
mkplot(c('all'), 'overall filesize distribution')
