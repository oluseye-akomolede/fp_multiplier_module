----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2024 06:24:42 PM
-- Design Name: 
-- Module Name: fp_mult_sig - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fp_mult_sig is
    Port ( 
            i_clk : in STD_LOGIC;
            s_axis_a_tvalid : IN STD_LOGIC;
            s_axis_a_tready : OUT STD_LOGIC;
            s_axis_a_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_axis_b_tvalid : IN STD_LOGIC;
            s_axis_b_tready : OUT STD_LOGIC;
            s_axis_b_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            m_axis_result_tvalid : OUT STD_LOGIC;
            m_axis_result_tready : IN STD_LOGIC;
            m_axis_result_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) 
            );
end fp_mult_sig;

architecture Behavioral of fp_mult_sig is

type t_state is ( 
                 idle,
                 store1,
                 store2,
                 check_zero1,
                 check_zero2,
                 execute_zero,
                 store3,
                 mult0,
                 mult1,
                 mult1_1,
                 mult1_2,
                 mult1_3,
                 mult1_4,
                 mult1_5,
                 mult1_6,
                 mult2,
                 mult3,
                 normalize1,
                 normalize2,
                 normalize3,
                 normalize4,
                 end_mult1,
                 end_mult1_1,
                 end_mult1_2,
                 end_mult2,
                 end_mult3,
                 end_mult4
                 
                 );

signal pr_state : t_state := idle;

signal left_sign : std_logic := '0';
signal left_exponent : signed(7 downto 0);
signal left_mantissa : unsigned(6 downto 0);

signal right_sign : std_logic := '0';
signal right_exponent : signed(7 downto 0);
signal right_mantissa : unsigned(6 downto 0);

signal result_sign : std_logic := '0';
signal result_exponent : signed(7 downto 0);
signal result_exponent_int : signed(15 downto 0);
signal result_mantissa : unsigned(6 downto 0);
signal result_vector : std_logic_vector(15 downto 0); 

signal zero_exponent : signed(7 downto 0) := (others => '0');
signal zero_mantissa : unsigned(6 downto 0) := (others => '0'); 
--signal int_mult : unsigned(15 downto 0); 
              
             

begin

    process(i_clk)
        variable leading_zero_count : integer := 0;
        variable pos_count : integer := 0;
        constant max_pos : integer := 6;
        variable le_int : signed(15 downto 0);
        variable re_int : signed(15 downto 0);
        
        variable lm_int : unsigned(7 downto 0);
        variable rm_int : unsigned(7 downto 0);
        
        variable int1 : unsigned(15 downto 0);
        variable int2 : unsigned(15 downto 0);
        variable int3 : unsigned(15 downto 0);
        variable int4 : unsigned(15 downto 0);
        variable int5 : unsigned(15 downto 0);
        variable int6 : unsigned(15 downto 0);
        variable int7 : unsigned(15 downto 0);
        variable int8 : unsigned(15 downto 0);
        
        variable a1 : unsigned(15 downto 0);
        variable a2 : unsigned(15 downto 0);
        variable a3 : unsigned(15 downto 0);
        variable a4 : unsigned(15 downto 0);
        variable a5 : unsigned(15 downto 0);
        variable a6 : unsigned(15 downto 0);
        variable a7 : unsigned(15 downto 0);
        variable a8 : unsigned(15 downto 0);
        
        variable int_mult : unsigned(15 downto 0); 
        
        variable res_temp : unsigned(6 downto 0);
        
    begin
        if rising_edge(i_clk) then
            case pr_state is
                when idle =>
                    left_sign <= '0';
                    left_exponent <= (others => '0');
                    left_mantissa <= (others => '0');
                    
                    right_sign <= '0';
                    right_exponent <= (others => '0');
                    right_mantissa <= (others => '0');
                    
                    result_sign <= '0';
                    result_exponent <= (others => '0');
                    result_exponent_int <= (others => '0');
                    result_mantissa <= (others => '0');
                    result_vector <= (others => '0');
                    
                    int_mult := (others => '0');
                    
                    leading_zero_count := 0;
                    pos_count := 0;
                    le_int := (others => '0');
                    re_int := (others => '0');
                    
                    lm_int := (others => '0');
                    rm_int := (others => '0');
                    
                    res_temp := (others => '0');
                    
                    int1 := (others => '0');
                    int2 := (others => '0');
                    int3 := (others => '0');
                    int4 := (others => '0');
                    int5 := (others => '0');
                    int6 := (others => '0');
                    int7 := (others => '0');
                    int8 := (others => '0');
                    
                    a1 := (others => '0');
                    a2 := (others => '0');
                    a3 := (others => '0');
                    a4 := (others => '0');
                    a5 := (others => '0');
                    a6 := (others => '0');
                    a7 := (others => '0');
                    a8 := (others => '0');
                    
                    s_axis_a_tready <= '1';
                    s_axis_b_tready <= '1';
                    m_axis_result_tvalid <= '0';
                    if s_axis_a_tvalid = '1' and s_axis_b_tvalid = '1' then
                        pr_state <= store1;
                    end if;
                    
                when store1 =>
                    left_sign <= s_axis_a_tdata(15);
                    left_exponent <= signed(s_axis_a_tdata(14 downto 7));
                    left_mantissa <= unsigned(s_axis_a_tdata(6 downto 0));
                    
                    right_sign <= s_axis_b_tdata(15);
                    right_exponent <= signed(s_axis_b_tdata(14 downto 7));
                    right_mantissa <= unsigned(s_axis_b_tdata(6 downto 0));
                    
                    s_axis_a_tready <= '0';
                    s_axis_b_tready <= '0';
                    
                    pr_state <= check_zero1;
                    
                when check_zero1 =>
                    if (left_exponent = zero_exponent and left_mantissa = zero_mantissa) then
                        pr_state <= execute_zero;
                    elsif (right_exponent = zero_exponent and right_mantissa = zero_mantissa) then
                        pr_state <= execute_zero;
                    else
                        pr_state <= mult0;
                    end if;
                    
                when execute_zero =>
                    result_sign <= '0';
                    result_exponent <= (others => '0');
                    result_mantissa <= (others => '0');
                    pr_state <= end_mult1;
                    
                when mult0 =>
                    le_int(7 downto 0) := left_exponent;
                    re_int(7 downto 0) := right_exponent;
                    lm_int(7) := '1';
                    rm_int(7) := '1';
                    lm_int(6 downto 0) := left_mantissa;
                    rm_int(6 downto 0) := right_mantissa;
                    pr_state <= mult1;
                    
                when mult1 =>
                    result_sign <= left_sign xor right_sign;
                    result_exponent_int <= le_int + re_int;
                    pr_state <= mult1_1;
                    
                when mult1_1 =>
                    --int_mult := lm_int * rm_int;
                    int_mult := (others => '0');
                    int1(7 downto 0) := lm_int;
                    int2 := shift_left(int1,1);
                    int3 := shift_left(int1,2);
                    int4 := shift_left(int1,3);
                    int5 := shift_left(int1,4);
                    int6 := shift_left(int1,5);
                    int7 := shift_left(int1,6);
                    int8 := shift_left(int1,7);
                    a1 := unsigned(resize(signed(rm_int(0 downto 0)),a1'length));
                    a2 := unsigned(resize(signed(rm_int(1 downto 1)),a1'length));
                    a3 := unsigned(resize(signed(rm_int(2 downto 2)),a1'length));
                    a4 := unsigned(resize(signed(rm_int(3 downto 3)),a1'length));
                    a5 := unsigned(resize(signed(rm_int(4 downto 4)),a1'length));
                    a6 := unsigned(resize(signed(rm_int(5 downto 5)),a1'length));
                    a7 := unsigned(resize(signed(rm_int(6 downto 6)),a1'length));
                    a8 := unsigned(resize(signed(rm_int(7 downto 7)),a1'length));
                    pr_state <= mult1_2;
                
                when mult1_2 =>
                    int1 := int1 and a1; 
                    int2 := int2 and a2;
                    int3 := int3 and a3;
                    int4 := int4 and a4;
                    int5 := int5 and a5;
                    int6 := int6 and a6;
                    int7 := int7 and a7;
                    int8 := int8 and a8; 
                    pr_state <= mult1_3;
                    
                when mult1_3 =>
                    int_mult := int1 +
                                int2 + 
                                int3;
                    pr_state <= mult1_4;
                    
                when mult1_4 =>
                    int_mult := int_mult +
                                int4 +
                                int5 +
                                int6;
                    pr_state <= mult1_5;
                    
                when mult1_5 =>
                    int_mult := int_mult +
                                int7 +
                                int8;
                    pr_state <= mult2;               
                
                
--                when mult1_2 =>
--                    if rm_int(0) = '1' then
--                        int_mult := int_mult + int1;
--                    end if;
--                    pr_state <= mult1_3;
                
--                when mult1_3 =>
--                    if rm_int(0) = '1' then
--                        int_mult := int_mult + int1;
--                    end if;
--                    pr_state <= mult1_4;
                    
--                when mult1_4 =>
--                    if rm_int(0) = '1' then
--                        int_mult := int_mult + int1;
--                    end if;
--                    pr_state <= mult1_5;
                    
--                when mult1_5 =>
--                    if rm_int(0) = '1' then
--                        int_mult := int_mult + int1;
--                    end if;
--                    pr_state <= mult1_6;
                    
--                when mult1_6 =>
--                    if rm_int(0) = '1' then
--                        int_mult := int_mult + int1;
--                    end if;
--                    pr_state <= mult1_7;
                    
--                when mult1_7 =>
--                    if rm_int(0) = '1' then
--                        int_mult := int_mult + int1;
--                    end if;
--                    pr_state <= mult1_8;
                    
--                when mult1_8 =>
--                    if rm_int(0) = '1' then
--                        int_mult := int_mult + int1;
--                    end if;
--                    pr_state <= mult1_3;
                    
--                when mult1_9 =>
--                    if rm_int(0) = '1' then
--                        int_mult := int_mult + int1;
--                    end if;
--                    pr_state <= mult2;
                    
                    
                    
                when mult2 =>
                    result_mantissa <= int_mult(13 downto 7);
                    result_exponent_int <= result_exponent_int - 127;
                    pr_state <= normalize1;
                    
                when normalize1 =>
                    leading_zero_count := -1;
                    pos_count := 15;
                    --result_mantissa <= result_mantissa_int(7 downto 1);
                    pr_state <= normalize2;
                    
                when normalize2 =>
                    if pos_count < 0 then
                        pr_state <= normalize4;
                    else
                        pr_state <= normalize3;
                    end if;
                    
                when normalize3 =>
                    if int_mult(pos_count) = '1' then
                        pr_state <= normalize4;
                    else
                        pos_count := pos_count - 1;
                        leading_zero_count := leading_zero_count + 1;
                        pr_state <= normalize2;
                    end if;
                
                when normalize4 =>
                    result_exponent_int <= result_exponent_int - leading_zero_count;
                    int_mult:= shift_left(int_mult,leading_zero_count);
                    pr_state <= end_mult1;
                    
                when end_mult1 =>
                    result_vector(15) <= result_sign;
                    result_vector(14 downto 7) <= std_logic_vector(result_exponent_int(7 downto 0));
                    res_temp := int_mult(13 downto 7);
                    pr_state <= end_mult1_1;
                    
                when end_mult1_1 =>
                    if int_mult(6) = '1' then
                        res_temp := res_temp + 1;
                    end if;
                    pr_state <= end_mult1_2;
                    
                when end_mult1_2 =>
                    result_vector(6 downto 0) <= std_logic_vector(res_temp);   
                    pr_state <= end_mult2;
                    
                when end_mult2 =>
                    if m_axis_result_tready = '1' then
                        pr_state <= end_mult3;
                    else
                        pr_state <= end_mult2;
                    end if;
                    
                when end_mult3 =>
                    m_axis_result_tdata <= result_vector;
                    m_axis_result_tvalid <= '1';
                    if s_axis_a_tvalid = '0' and s_axis_b_tvalid = '0' then
                        pr_state <= idle;
                    else
                        pr_state <= end_mult3;
                    end if; 
                    
                    
                    
                when others =>
                    pr_state <= idle;
            end case;
        end if;
    end process;


end Behavioral;
