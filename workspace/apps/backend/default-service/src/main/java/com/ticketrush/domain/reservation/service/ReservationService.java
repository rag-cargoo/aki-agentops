package com.ticketrush.domain.reservation.service;

import com.ticketrush.domain.concert.entity.Seat;
import com.ticketrush.domain.concert.repository.SeatRepository;
import com.ticketrush.domain.reservation.entity.Reservation;
import com.ticketrush.domain.reservation.repository.ReservationRepository;
import com.ticketrush.domain.user.User;
import com.ticketrush.domain.user.UserRepository;
import com.ticketrush.interfaces.dto.ReservationRequest;
import com.ticketrush.interfaces.dto.ReservationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final SeatRepository seatRepository;
    private final UserRepository userRepository;

    @Transactional
    public ReservationResponse createReservation(ReservationRequest request) {
        // 1. 유저 조회
        User user = userRepository.findById(request.userId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // 2. 좌석 조회 (Lock은 추후 적용)
        Seat seat = seatRepository.findById(request.seatId())
                .orElseThrow(() -> new IllegalArgumentException("Seat not found"));

        // 3. 좌석 점유 시도
        seat.reserve();

        // 4. 예약 생성
        Reservation reservation = new Reservation(user, seat);
        reservationRepository.save(reservation);

        return ReservationResponse.from(reservation);
    }
}
