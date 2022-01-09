FROM ruby:2.7

ENV LANG C.UTF-8
# Rails6 までは、何かと Node.js, NPM を要する。
RUN apt-get update -qq
RUN apt-get install -y \
      nodejs \
      build-essential

# yarn のセットアップ
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
ENV PATH /root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:$PATH

# Rails のデフォルトポート
# どのみち Docker Compose で -p するので、指定しなくても良いのだが 
EXPOSE 3000

# 作業ディレクトリを作成し、そこへ移動
ENV APP_ROOT /app
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

# デバッグ用の SSH ポート。
# RubyMine 等の JetBrains の IDE で、既存コンテナで開発するには、
# 単純な SSH 連携が良い。
# Docker 連携や Docker Compose 連携は、コンテナの start, stop 等、
# 余計なことをする
RUN echo "export PATH=$PATH" >> /etc/profile
RUN apt-get install -y openssh-server
RUN echo 'root:password' | chpasswd
RUN sed -i -E 's/^.?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
EXPOSE 22
RUN mkdir /var/run/sshd
ENTRYPOINT ["/usr/sbin/sshd", "-D"]

# bundle install は、どうせ開発中にはたびたび実行することなので、手実行を決め込む

# webpackerの設定
# RUN rails webpacker:install
