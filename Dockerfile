FROM openjdk:8u171-jdk-stretch

COPY data data
COPY libs libs
COPY drivers drivers

COPY FoodMartLoader.sh .
COPY foodmart-schema.sql .

ENTRYPOINT ["./FoodMartLoader.sh"]
