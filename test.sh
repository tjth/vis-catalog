sudo docker run -it \
                -v $(pwd):/src \
                -v /data:/src/db \
                -p 3123:3123 \
                --name rails-test \
                rails \
                '/bin/bash' \
                '-c' '-l' 'rake spec'

