# Honor system-wide environment variables
if [[ -f /etc/profile ]]; then
	source /etc/profile
fi

() {
	setopt NULL_GLOB
        local dir
	for dir in \
		~/bin \
		~/usr/bin \
		~/.gem/ruby/*/bin \
		~/.local/bin \
	; do
		if [[ -d $dir && ${path[(i)$dir]} -gt ${#path} ]]; then
			path=( $dir $path )
		fi
	done
}
