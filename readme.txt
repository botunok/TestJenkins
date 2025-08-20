//Для локальной сборки контейнера используем команду:
docker build --network host -t TestJenkins .

//для запуска контейнера использовать команду:
 docker run -p 9090:9090 TestJenkins

//Для проверки успеха использовать вызов
http://localhost:9090/test