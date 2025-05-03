# Advanced Login

implementation of the "remember me" feature.
Remember token based on permanent cookies.


## Remember token

first step toward persistent sessions by generating a signed remember token
appropriate for creating permanent cookies.

plan for creating persistent sessions:

1. Create a signed token.
2. Place the token in the browser cookies with an expiration date far in the future.
3. Place the signed remember token in the browser cookies.
4. When presented with a cookie containing the signed remember token,
   verify the remember token cookie and
   extract the user_id to login.


example of how generating and verifying a token works.

```sh
iex -S mix
```
```elixir
iex> user_id = 1
1

iex> token = Phoenix.Token.sign(SampleAppWeb.Endpoint, "user salt", user_id)
"SFMyNTY.g2gDYQFuBgD0n5_LfQFiAAFRgA.7OOb1Pq_GHILjnfbqfaRtFs8Efm5G-T_batK_mvX7Ms"

iex> Phoenix.Token.verify(SampleAppWeb.Endpoint, "user salt", token, \
...> max_age: :infinity)
{:ok, 1}
```
