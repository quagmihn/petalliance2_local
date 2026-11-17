<GameProjectFile>
  <PropertyGroup Type="Layer" Name="itemInfoLayer" ID="89d83339-a364-432d-97c6-c88aec170aa3" Version="2.0.6.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="5" Speed="1.0000">
        <Timeline ActionTag="-1499861690" FrameType="PositionFrame">
          <PointFrame FrameIndex="0" X="320.0000" Y="568.0000" />
          <PointFrame FrameIndex="5" X="320.0000" Y="568.0000" />
        </Timeline>
        <Timeline ActionTag="-1499861690" FrameType="ScaleFrame">
          <PointFrame FrameIndex="0" X="0.0001" Y="0.0001" />
          <PointFrame FrameIndex="5" X="1.0000" Y="1.0000" />
        </Timeline>
        <Timeline ActionTag="-1499861690" FrameType="RotationSkewFrame">
          <PointFrame FrameIndex="0" X="0.0000" Y="0.0000" />
          <PointFrame FrameIndex="5" X="0.0000" Y="0.0000" />
        </Timeline>
      </Animation>
      <ObjectData Name="Layer" FrameEvent="" Tag="160" ctype="LayerObjectData">
        <Position X="0.0000" Y="0.0000" />
        <Scale ScaleX="1.0000" ScaleY="1.0000" />
        <AnchorPoint />
        <CColor A="255" R="255" G="255" B="255" />
        <Size X="480.0000" Y="520.0000" />
        <PrePosition X="0.0000" Y="0.0000" />
        <PreSize X="0.0000" Y="0.0000" />
        <Children>
          <NodeObjectData Name="db" ActionTag="-1376350185" FrameEvent="" Tag="295" ObjectIndex="1" TouchEnable="True" FontSize="14" ButtonText="" Scale9Enable="True" Scale9Width="1" Scale9Height="1" ctype="ButtonObjectData">
            <Position X="240.0000" Y="260.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <CColor A="255" R="255" G="255" B="255" />
            <Size X="640.0000" Y="1136.0000" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.3333" Y="2.1846" />
            <Children>
              <NodeObjectData Name="board" ActionTag="-1499861690" FrameEvent="" Tag="161" ObjectIndex="1" Scale9Width="480" Scale9Height="520" ctype="ImageViewObjectData">
                <Position X="320.0000" Y="568.0000" />
                <Scale ScaleX="0.0001" ScaleY="0.0001" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <CColor A="255" R="255" G="255" B="255" />
                <Size X="480.0000" Y="520.0000" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="0.0000" Y="0.0000" />
                <Children>
                  <NodeObjectData Name="itemName" ActionTag="-685570525" FrameEvent="" Tag="162" ObjectIndex="1" FontSize="28" LabelText="普通精灵球" ctype="TextObjectData">
                    <Position X="240.0000" Y="420.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="140.0000" Y="28.0000" />
                    <PrePosition X="0.5000" Y="0.8077" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FontResource Type="Normal" Path="haibao.ttf" />
                  </NodeObjectData>
                  <NodeObjectData Name="itemDesc" ActionTag="-1598236537" FrameEvent="" Tag="163" ObjectIndex="2" FontSize="24" LabelText="" IsCustomSize="True" ctype="TextObjectData">
                    <Position X="240.0000" Y="369.9999" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <Size X="240.0000" Y="210.0000" />
                    <PrePosition X="0.5000" Y="0.7115" />
                    <PreSize X="0.5000" Y="0.4038" />
                    <FontResource Type="Normal" Path="cuyuan_GBK.ttf" />
                  </NodeObjectData>
                </Children>
                <FileData Type="Normal" Path="Searching/Common/tn_tips.png" />
              </NodeObjectData>
            </Children>
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="Normal" Path="empty.png" />
            <PressedFileData Type="Normal" Path="empty.png" />
            <NormalFileData Type="Normal" Path="empty.png" />
          </NodeObjectData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameProjectFile>