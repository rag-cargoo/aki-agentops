package com.ticketrush.domain.concert.service;

import com.ticketrush.domain.concert.entity.Concert;
import com.ticketrush.domain.concert.entity.ConcertOption;
import com.ticketrush.domain.concert.entity.Seat;
import com.ticketrush.domain.concert.repository.ConcertRepository;
import com.ticketrush.domain.concert.repository.SeatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ConcertService {

    private final ConcertRepository concertRepository;
    private final SeatRepository seatRepository;

    @Transactional(readOnly = true)
    public List<Concert> getConcerts() {
        return concertRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<ConcertOption> getConcertOptions(Long concertId) {
        Concert concert = concertRepository.findById(concertId)
                .orElseThrow(() -> new IllegalArgumentException("Concert not found"));
        return concert.getOptions();
    }

    @Transactional(readOnly = true)
    public List<Seat> getAvailableSeats(Long concertOptionId) {
        return seatRepository.findByConcertOptionIdAndStatus(concertOptionId, Seat.SeatStatus.AVAILABLE);
    }
}
