#LogLevel debug

LogFormat "{ \"time\":\"%t\", \"remoteIP\":\"%a\", \"host\":\"%V\", \"port\": \"%p\", \"request\":\"%U\", \"query\":\"%q\", \"method\":\"%m\", \"status\":\"%>s\", \"response_time\": %%{ms}T }" customJSON
CustomLog /proc/self/fd/1 customJSON
