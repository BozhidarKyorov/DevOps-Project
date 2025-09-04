INSERT INTO users (name, email)
VALUES ('Ivan', 'ivan@example.com'),
       ('Petya', 'petya@example.com')
ON CONFLICT DO NOTHING;