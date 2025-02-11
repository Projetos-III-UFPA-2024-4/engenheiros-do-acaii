const SplashComponent: React.VFC = () => {
  return (
    <Splash>
      <loaderImage />
      <logoImage />
    </Splash>
  )
}

const Splash = styled.View`
  height: 852px;
  width: 393px;
  background-color: #662d91;
`
const loaderImage = styled.View`
  height: 40px;
  width: 40px;
  background-color: #ffffff;
`
const logoImage = styled.View`
  height: 187px;
  width: 314px;
  background-color: #ffffff;
`
