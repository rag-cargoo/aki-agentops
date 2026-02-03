#!/bin/bash

# Remove duplicate domain entities (Safe to delete as they were moved to 'entity' package)
rm -f src/main/java/com/ticketrush/domain/concert/Concert.java
rm -f src/main/java/com/ticketrush/domain/concert/ConcertOption.java
rm -f src/main/java/com/ticketrush/domain/concert/Seat.java
rm -f src/main/java/com/ticketrush/domain/reservation/Reservation.java

# Remove duplicate repositories (Safe to delete as they were moved to 'repository' package)
rm -f src/main/java/com/ticketrush/domain/concert/ConcertOptionRepository.java
rm -f src/main/java/com/ticketrush/domain/concert/ConcertRepository.java
rm -f src/main/java/com/ticketrush/domain/concert/SeatRepository.java
rm -f src/main/java/com/ticketrush/domain/reservation/ReservationRepository.java

# Remove application services (Safe to delete as they were moved to 'domain/service' package)
rm -f src/main/java/com/ticketrush/application/ConcertService.java
rm -f src/main/java/com/ticketrush/application/ReservationService.java
rmdir src/main/java/com/ticketrush/application

# Remove interfaces API controllers (Safe to delete as they were moved to 'domain/controller' package)
rm -f src/main/java/com/ticketrush/interfaces/api/ConcertController.java
rm -f src/main/java/com/ticketrush/interfaces/api/ReservationController.java
rmdir src/main/java/com/ticketrush/interfaces/api
