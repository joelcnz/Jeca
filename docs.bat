dmd -D -c all.d base.d bmp.d -d
if %1==view (
	all.html
	base.html
	bmp.html
)
