pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
block_unit = 8; 
side = 8
pp = {
    -- color
    -- type
    -- x
    -- y
}

CURSOR_X =1
CURSOR_Y =side
OLD_X = 1
OLD_Y = side
turno = 'W'
is_pressed = false
piece = ''
moves={}

function _init()
    for i=0,15 do
		palt(i, i==2)
	end -- assicura che il colore 1 (e altri) siano opachi
    prepare_setup()
end

function prepare_setup()
    local pawn_y = {2,7}
    local pawn_x = {1,2,3,4,5,6,7,8}

    local rock_y = {1,8}
    local rock_x = {1,8}

    local knight_y = {1,8}
    local knight_x = {2,7}

    local bishop_y = {1,8}
    local bishop_x = {3,6}

    local queen_y = {1,8}
    local queen_x = {4,4}

    local king_y = {1,8}
    local king_x = {5,5}

    local piece_map_type = {'R', 'K', 'B', 'Q', 'N'}
    local piece_map = {rock_x, knight_x, bishop_x, queen_x, king_x}

    add_pieces(pawn_x, pawn_y, 'P', 16)
    add_pieces(bishop_x, bishop_y, 'B', 17)
    add_pieces(rock_x, rock_y, 'R', 18)
    add_pieces(knight_x, knight_y, 'N', 19)
    add_pieces(queen_x, queen_y, 'Q', 20)
    add_pieces(king_x, king_y, 'K',21)

end

function add_pieces(x_list, y_list, type, template)
    for i=1, #y_list do
        for j=1, #x_list do
            local color = assign_color(y_list[i])
            local offset = color =='W' and 0 or 16
            add(pp, {
                x = x_list[j],
                y = y_list[i],
                color = color,
                type = type, 
                template = template + offset
            })
        end
    end
end


function _update()
    update()
end

function update()
    
    if         btnp(0) then cursor_move_in_border(-1,0)
        elseif btnp(1) then cursor_move_in_border(1,0)
        elseif btnp(2) then cursor_move_in_border(0,-1)
        elseif btnp(3) then cursor_move_in_border(0,1)
    end
    -- gestione selezioe e mosse
    if btnp(4) then 
        -- selezione elemento grafico le mosse possibili
        if (is_pressed) then
            if move_exists(OLD_X,OLD_Y, CURSOR_X, CURSOR_X) then
                muovi_pezzo(OLD_X, OLD_Y, CURSOR_X, CURSOR_Y)
                turno = turno =='W' and 'W' or 'B'
            end
            is_pressed = false   
        else 
            piece = find_piece(CURSOR_X, CURSOR_Y, turno)
            if piece then
                refresh_available_moves(turno, CURSOR_X, CURSOR_Y, piece)
                OLD_X = CURSOR_X
                OLD_Y = CURSOR_Y
                is_pressed = true
            end
            
        end
    end
    
end
function move_exists(old_x,old_y, new_y, new_x)
    for move in all(moves) do
        if (    
                move.pos_x ==old_x and 
                move.pos_y ==old_y and 
                move.x     ==new_x and
                move.y     ==new_y 
            ) then 
            return true
        end
    end
    return false
end

function muovi_pezzo(old_x,old_y, new_y, new_x)
    for pezzo in all(pp) do 
        if pezzo.x == old_x and pezzo.y == old_y then 
            local new_pezzo = pezzo
            del(pp, pezzo)
            
            pezzo.x = new_x
            pezzo.y = new_y

            add(pp, pezzo)
            return
        end
    end
end

function find_piece(x,y, turno)
    for pezzo in all(pp) do 
        if pezzo.x == x and pezzo.y == y and pezzo.color == turno then
            return pezzo.type
        end
    end
    return false
end


function draw_pieces()
    foreach(pp, function (piece)
        spr(piece.template, piece.x *block_unit, piece.y*block_unit, 1,1)
    end)
end

function assign_color(y)
    local color = y>=4 and 'W' or 'B'
    return color
end



function cursor_move_in_border(x,y)
    CURSOR_X = min(max(CURSOR_X + x,1),side)
    CURSOR_Y = min(max(CURSOR_Y + y,1),side)
end

function _draw()
    
    cls()
    draw_chessboard()
    draw_pieces()
    draw_moves()
    draw_cursor()
end

function draw_moves()
    foreach(moves, function (move)
        
        printh(tostr(move.x)..', '..tostr(move.y), 'my_logs', false)
        spr(3, move.x * block_unit, move.y * block_unit, 1,1)
    end)
end

function draw_cursor() 
    spr(2,CURSOR_X*block_unit, CURSOR_Y*block_unit, 1,1)
end
-->8
function draw_chessboard()
    local sprt;
    for i=1, side do
        for j=1, side do 
            sprt = ((i%2)+j)%2 == 0 and 0 or 1
            spr(sprt,i *block_unit,j*block_unit,1,1)
        end
    end
end

knight_moves = {
  {1, 2}, {2, 1}, 
  {-1, 2}, {-2, 1},
  {1, -2}, {2, -1}, 
  {-1, -2}, {-2, -1}
}

king_moves ={
    {-1, 1},{ 1,0},{ 1, 1}, 
    { 0,-1},       { 0, 1},
    {-1,-1},{-1,0},{-1,-1}, 
}

rook_dirs = {
    {1, 0}, {-1, 0}, {0, 1}, {0, -1}
}

bishop_dirs ={
    {1,1}, {1,-1}, {-1,1}, {-1,-1}
}

queen_dirs ={
    {1, 0}, {-1, 0}, {0, 1}, {0, -1},
    {1,1}, {1,-1}, {-1,1}, {-1,-1}
}

function refresh_available_moves(color, x, y, piece)
    moves = {}
    if piece == 'P' then 
        add_pawn_positions(color, x, y)
    elseif piece == 'N' then 
        add_simple_positions(color, x, y, knight_moves)
    elseif piece == 'K' then 
        add_simple_positions(color, x, y, king_moves)
    elseif piece == 'R' then
        add_directions(color, x,y,rook_dirs)
    elseif piece == 'B' then
        add_directions(color, x,y, bishop_dirs)
    elseif piece == 'Q' then
        add_directions(color, x,y, queen_dirs)
    else 
    end
end 

function add_pawn_positions(color, x, y)
    local pos_x = x
    local pos_y = y
    local dir = color == 'W' and -1 or 1
    local start_row = color == 'W' and 7 or 2
    local next_y = y + dir

    -- Avanzamento singolo
    if is_valid(x, next_y) and is_empty(x, next_y) then
        add(moves, {pos_x=pos_x, pos_y=pos_y, x=x, y=next_y})

        -- Avanzamento doppio dalla posizione iniziale
        local next2_y = y + dir * 2
        if y == start_row and is_valid(x, next2_y) and is_empty(x, next2_y) then
            add(moves, {pos_x=pos_x, pos_y=pos_y,x=x, y=next2_y})
        end
    end

    -- Catture diagonali
    for dx in all({-1, 1}) do
        local cx = x + dx
        local cy = y + dir
        if is_valid(cx, cy) and is_enemy(cx, cy, color) then
            add(moves, {pos_x=pos_x, pos_y=pos_y,x=cx, y=cy})
        end
    end
end


function add_simple_positions(color, pos_x, pos_y, position_table)
    for d in all(position_table) do
        local x = pos_x + d[1]
        local y = pos_y + d[2]
        if is_valid(x, y) and is_empty_or_enemy(x, y, color) then
            add(moves, {pos_x=pos_x, pos_y=pos_y, x=x, y=y})
        end
    end
    return moves
end

function add_directions(color, pos_x, pos_y, direction_table)
    for dir in all(direction_table) do
    local x = pos_x + dir[1]
    local y = pos_y + dir[2]
        while is_valid(x, y) and is_empty_or_enemy(x, y, color) do
            add(moves, {pos_x=pos_x, pos_y=pos_y, x=x, y=y})
            if is_enemy(x, y, color) then break end
            x += dir[1]
            y += dir[2]
        end
    end
end
function is_valid(x,y)
    return (x>0 and x<=side and y>0 and y<=side)
end

function is_empty(x, y)
    for piece in all(pp) do
        if piece.x == x and piece.y == y then
            return false
        end
    end
    return true
end

function is_empty_or_enemy(x, y, color)
    return is_empty(x, y) or is_enemy(x, y, color)
end

function is_enemy(x, y, color)
    for piece in all(pp) do
        if piece.x == x and piece.y == y and piece.color ~= color then
            return true
        end
    end
    return false
end



__gfx__
666666663333333322888822aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
677777763bbbbbb328222282a222222a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
677777763bbbbbb382222228a222222a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
677777763bbbbbb382222228a222222a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
677777763bbbbbb382222228a222222a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
677777763bbbbbb382222228a222222a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
677777763bbbbbb328222282a222222a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666663333333322888822aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222212aa2a22227a22200000000000000000000000000000000000000000000000000000000000000000000000000000000
2221722222217222221226222221762221777aa221711aa200000000000000000000000000000000000000000000000000000000000000000000000000000000
2211772222117622221776222217222222177a222277772200000000000000000000000000000000000000000000000000000000000000000000000000000000
22177622222162222221722221216222222172222221722200000000000000000000000000000000000000000000000000000000000000000000000000000000
22276222222162222221722222217222222172222221722200000000000000000000000000000000000000000000000000000000000000000000000000000000
2211772222217222221776222221722222177a2222177a2200000000000000000000000000000000000000000000000000000000000000000000000000000000
211776622211772222177722221126222217772222177a2200000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222217227a22172277200000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222212112122221122200000000000000000000000000000000000000000000000000000000000000000000000000000000
22211222222112222212212222211122211111122112211200000000000000000000000000000000000000000000000000000000000000000000000000000000
22111122221111222211112222112222221111222211112200000000000000000000000000000000000000000000000000000000000000000000000000000000
22111122222112222221122221211222222112222221122200000000000000000000000000000000000000000000000000000000000000000000000000000000
22211222222112222221122222211222222112222221122200000000000000000000000000000000000000000000000000000000000000000000000000000000
22111122222112222211112222211222221111222211112200000000000000000000000000000000000000000000000000000000000000000000000000000000
21111112221111222211112222112122221111222211112200000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222211221122112211200000000000000000000000000000000000000000000000000000000000000000000000000000000
