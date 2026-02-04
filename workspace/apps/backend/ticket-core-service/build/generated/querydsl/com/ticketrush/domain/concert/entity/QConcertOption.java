package com.ticketrush.domain.concert.entity;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QConcertOption is a Querydsl query type for ConcertOption
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QConcertOption extends EntityPathBase<ConcertOption> {

    private static final long serialVersionUID = -352251131L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QConcertOption concertOption = new QConcertOption("concertOption");

    public final QConcert concert;

    public final DateTimePath<java.time.LocalDateTime> concertDate = createDateTime("concertDate", java.time.LocalDateTime.class);

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public QConcertOption(String variable) {
        this(ConcertOption.class, forVariable(variable), INITS);
    }

    public QConcertOption(Path<? extends ConcertOption> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QConcertOption(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QConcertOption(PathMetadata metadata, PathInits inits) {
        this(ConcertOption.class, metadata, inits);
    }

    public QConcertOption(Class<? extends ConcertOption> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.concert = inits.isInitialized("concert") ? new QConcert(forProperty("concert"), inits.get("concert")) : null;
    }

}

