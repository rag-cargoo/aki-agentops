package com.ticketrush.domain.agency;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;


/**
 * QAgency is a Querydsl query type for Agency
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QAgency extends EntityPathBase<Agency> {

    private static final long serialVersionUID = -1494267679L;

    public static final QAgency agency = new QAgency("agency");

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath name = createString("name");

    public QAgency(String variable) {
        super(Agency.class, forVariable(variable));
    }

    public QAgency(Path<? extends Agency> path) {
        super(path.getType(), path.getMetadata());
    }

    public QAgency(PathMetadata metadata) {
        super(Agency.class, metadata);
    }

}

