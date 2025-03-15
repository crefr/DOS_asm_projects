#ifndef SFML_UI_INCLUDED
#define SFML_UI_INCLUDED

typedef struct {
    sf::Shape * shape;
    sf::Vector2i pos;
    sf::Vector2i size;

    sf::Text text;
    bool is_active;

    char * buffer;
    size_t text_size;
    size_t max_text_size;
} text_field_t;

typedef struct {
    sf::Shape * shape;
    sf::Vector2i pos;
    sf::Vector2i size;

    void (*handler_func)(sf::RenderWindow *);
} button_t;


text_field_t newTextField(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size, sf::Font * font, sf::Color color, unsigned int char_size, char * buffer, size_t max_text_size);

void drawTextField(sf::RenderWindow * window, text_field_t * text_f);

void textFieldNewChar(text_field_t * text_f, char new_char);

void checkActiveField(text_field_t * text_f, sf::Vector2i mouse_pos);


button_t newButton(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size, void (*handler_func)(sf::RenderWindow *));

void drawButton(sf::RenderWindow * window, button_t * button);

void checkButton(sf::RenderWindow * window, button_t * button, sf::Vector2i mouse_pos);

#endif
